class UserNotifierMailerPreview < ActionMailer::Preview

  def send_token
    @user = User.first
    @token = "12345"
    UserNotifierMailer.send_token(@user, @token)
  end

  def send_visit_email
    opts = {
      user_id: User.first.id,
      visit_id: Visit.first.id
    }
    UserNotifierMailer.send_visit_email(opts)
  end  

end
