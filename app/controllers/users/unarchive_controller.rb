class Users::UnarchiveController < ApplicationController
  before_action :set_organization_from_user
  before_action :set_user

  def destroy
    authorize @user, policy_class: Users::UnarchivePolicy

    if @user.unarchive!
      redirect_back(fallback_location: root_path, notice: "#{@user.type} Unarchived")
    else
      redirect_back(fallback_location: root_path, alert: "Something went wrong")
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
