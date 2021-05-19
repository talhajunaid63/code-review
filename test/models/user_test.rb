require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'test user with a phone is valid ' do
    user = User.new(phone: "555 333 1234")
    assert user.valid?
  end

  test 'test user with a wrong phone is not valid ' do
    user = User.new(phone: "555 333 12")
    assert !user.valid?
  end

  test 'test user with an email is valid ' do
    user = User.new(email: "new_user@fake.me")
    assert user.valid?
  end

  test 'test user with a wrong email is not valid ' do
    user = User.new(email: "new_user@fake")
    assert !user.valid?
  end

  test 'Can exists several users with blank phone' do
    assert_difference 'User.count', 2 do
      create_two_users_with_blank_phone
    end
  end

  def create_two_users_with_blank_phone
    user = User.new(email: "new_user1@fake.me", phone: "")
    user.save

    user = User.new(email: "new_user2@fake.me", phone: "")
    user.save
  end
end
