class Users::ArchiveController < ApplicationController
  before_action :set_organization_from_user
  before_action :set_user

  def create
    authorize @user, policy_class: Users::ArchivePolicy

    if @user.archive!
      redirect_back(fallback_location: root_path, notice: "#{@user.type} Archived")
    else
      redirect_back(fallback_location: root_path, alert: "Something went wrong")
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
