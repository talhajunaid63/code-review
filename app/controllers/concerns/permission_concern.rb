module PermissionConcern
  extend ActiveSupport::Concern

  included do
    before_action :ensure_tier_permission
  end

  def ensure_tier_permission
    object = permify_params[:object]
    action = permify_params[:action]

    return if object.can?(action)

    error_message = 'You are not authorized to perform this action.'
    flash[:alert] = error_message
    respond_to do |format|
      format.html { redirect_to main_route }
      format.js { return render 'shared/error' }
      format.json { return render json: { error: error_message } }
    end
  end
end
