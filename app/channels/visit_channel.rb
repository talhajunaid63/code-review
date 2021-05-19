class VisitChannel < ApplicationCable::Channel
  def subscribed
    visit.mark_present!(current_user)
    stream_for visit

    NotificationService.perform(visit) if current_user.patient?
    refresh_timer
    user_transitioned("enter")
  end

  def unsubscribed
    visit.mark_absent!(current_user)
    refresh_timer
    user_transitioned("leave")

    stop_all_streams
    ActionCable.server.remote_connections.where(current_user: current_user).disconnect
  end

  def send_notification(data)
    self.class.broadcast_to visit, message: data['message'], attributes: data['attributes'], type: 'alert'
  end

  def send_message(data)
    self.class.broadcast_to visit, message: message(data), type: 'chat'
  end

  def send_codecs(data)
    CodecService.perform(visit, current_user, data['codecs'])
  end

  def heartbeat
    visit.refresh_attendance!(current_user)
  end

  private

  def user_transitioned(type)
    send_message("type" => type, "visit_id" => @visit.id)
  end

  def message(data)
    ApplicationController.render(
      partial: 'organizations/visits/chat_message',
      locals: {
        user: current_user,
        message_type: data['type'],
        content: data['message']
      }
    )
  end

  def visit
    @visit ||= Visit.unscoped.find_by(id: params[:visit_id])
  end

  def timer(user)
    ApplicationController.render(
      partial: 'organizations/visits/timer',
      locals: {
        visit: visit,
        current_user: user
      }
    )
  end

  def refresh_timer
    return unless current_user.patient?

    options = { visit_id: visit.id, type: "refresh_visit" }
    visit.non_patient_participants.each do |participant|
      UserChannel.broadcast_to participant, options
    end
  end
end
