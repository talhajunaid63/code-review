class Recordings::CreateService < ApplicationService

  def initialize(params)
    @session_id = params[:sessionId]
    @recorded_at = Time.at(params[:createdAt] / 1000).to_datetime rescue nil
    @duration = params[:duration]
    @tok_id = params[:id]
    @size = params[:size]
    @url = params[:url]
    @project_id = params[:projectId]
  end

  def perform
    @visit = Visit.find_by(tok_session_id: @session_id)
    return Result.new(nil, false) unless @visit

    @visit_recording = VisitRecording.new(
      visit: @visit,
      organization: @visit.organization,
      recorded_at: @recorded_at,
      duration: @duration,
      tok_id: @tok_id,
      tok_session_id: @session_id,
      size: @size,
      url: @url,
      expired_at: VisitRecording::EXPIRY.since
    )

    if @visit_recording.save
      if @visit.organization.paid_subscription?
        StripeUsageRecordJob.perform_later(
          @visit_recording.organization_id,
          VisitRecording::RECORDING_PLAN_NAME,
          @visit_recording.duration_in_minutes.round
        )
      end

      S3CopierJob.perform_later(organization.id, source, target) if organization.bucket_connected?

      Result.new(@visit_recording, true)
    else
      Result.new(@visit_recording, false)
    end
  end

  private

  def organization
    @organization ||= @visit_recording.organization
  end

  def source
    "#{@project_id}/#{@tok_id}/archive.mp4"
  end

  def target
    "#{organization.slug}/#{@visit.id}/recording_#{@visit_recording.id}"
  end
end
