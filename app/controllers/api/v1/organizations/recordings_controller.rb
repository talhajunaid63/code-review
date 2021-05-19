class Api::V1::Organizations::RecordingsController < ApiController
  before_action :authorize_app
  before_action :set_org
  before_action :set_recording, only: [:show]

  include PermissionConcern

  def index
    @recordings = @organization
                    .visit_recordings
                    .order(created_at: :asc)
                    .page(params[:page])
                    .per(VisitRecording::PER_PAGE)
  end

  def show
    @video_url = Recordings::S3Service.new(@recording).presigned_url
  end

  private

  def set_recording
    @recording = VisitRecording.find(params[:id])
  end

  def set_org
    @organization = Organization.find(params[:organization_id])
  end

  def permify_params
    { object: @organization, action: Permission::SYSTEM_INTEGRATION }
  end
end
