class Authentication < ApplicationRecord
  TOKEN_EXPIRY = 30.minutes

  validates :login_handler, presence: true, uniqueness: true
  validates :login_handler, format: { with: User::VALID_PHONE_NUMBER_REGEX }, numericality: { only_integer: true }, if: :phone?
  validates :login_handler, format: { with: User::VALID_EMAIL_REGEX }, if: :email?

  def self.for(login_handler)
    self.transaction do
      if User.for(login_handler).exists?
        where(login_handler: User.normalize_login_handler(login_handler)).first_or_create
      end
    end
  end

  def users
    User.for(login_handler)
  end

  def authenticate(t)
    return false if token.blank?
    return false if !token_valid?
    return false if token != t

    return true
  end

  def phone?
    !!(login_handler =~ User::VALID_PHONE_NUMBER_REGEX)
  end

  def email?
    !!(login_handler =~ User::VALID_EMAIL_REGEX)
  end

  def token_valid?
    return false if token.blank?
    return false if token_expired_at.blank?
    return false if token_expired_at < Time.now

    true
  end

  def create_token(options = {})
    self.token = generate_token unless token_valid?
    self.token_expired_at = TOKEN_EXPIRY.since
    save validate: false

    return if options[:skip_notifications]

    if email?
      AuthenticationMailer.token(self.id).deliver_later
    elsif phone?
      TextMessage.send_text("#{token} is your sign in code.", login_handler)
    end

    true
  end

  def test_account?
    phone? && TextMessage.test_number?(login_handler) || email? && login_handler.last(8) == '@fake.me'
  end

  def generate_token
    test_account? ? '12345' : rand(10009...99999).to_s
  end
end
