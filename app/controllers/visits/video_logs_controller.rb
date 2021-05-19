class Visits::VideoLogsController < ApiController
  before_action :authenticate_user
  before_action :set_visit
  skip_before_action :restrict_demo_user

  def show
    authorize @visit, policy_class: Organizations::VideoLogPolicy

    redirect_to organization_visit_path(@visit.organization, @visit)
  end

  def create
    video_log = @visit.video_logs.new(content: params[:content], user_id: current_user.id)
    authorize @visit, policy_class: Visits::VideoLogPolicy

    video_log.set_browser_meta browser

    if video_log.save
      head :ok
    else
      throw_400 video_log.error_message
    end
  end

  private

  def set_visit
    @visit = Visit.unscoped.find params[:visit_id]
  end
end
