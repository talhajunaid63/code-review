class Api::V1::LegalReleasesController < ApiController
  before_action :authorize_app

  def create
    @legal_release = LegalRelease.new(legal_release_params)
    if @legal_release.save_release
      render json: {
        message: "Legal Release Created",
        }, status: 200
    else
      throw_500(@message ? @message : "Not created")
    end
  end

  private

  def legal_release_params
    params.require(:legal_release).permit(
      :visit_id,
      :user_id,
      :confirmation,
    )
  end
end
