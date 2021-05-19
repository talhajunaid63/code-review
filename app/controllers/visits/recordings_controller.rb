class Visits::RecordingsController < ApplicationController
  before_action :authenticate_user, except: [:create]
  skip_before_action :verify_authenticity_token

  def show
    @recording = current_user.organization.visit_recordings.find_by(id: params[:id])
    return not_available unless @recording

    s3_resource = Recordings::S3Service.new(@recording)
    return not_available unless s3_resource.exists?

    @recording.downloaded!
    @download_url = s3_resource.download_url

    respond_to do |format|
      format.html { redirect_to @download_url }
      format.js
    end
  end

  def create
    case params[:status]
    when "uploaded"
      result = Recordings::CreateService.new(params).perform
      if result.success?
        head :ok
      else
        head :bad_request
      end
    else
      head :ok
    end
  end

  private

  def not_available
    @error_message = "Sorry this recording does not exist"

    respond_to do |format|
      format.html do
        redirect_back_or_to root_path, alert: @error_message
      end
      format.js
    end
  end
end
