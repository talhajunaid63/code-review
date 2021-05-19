class UserChannel < ApplicationCable::Channel
  def subscribed
    current_user.mark_online!
    stream_for current_user
  end

  def unsubscribed
    current_user.mark_offline!
  end
end
