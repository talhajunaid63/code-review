class Organizations::Visits::RightNowVisitsController < ApplicationController
  before_action :authenticate_user
  before_action :set_org

  include PermissionConcern

  def new
    @visit_order = VisitOrder.new(organization_id: @organization.id)
  end

  def create
    result = ::Visits::RightNow::CreateService.new(visit_params).perform
    @visit = result.resource
    if result.success?
      log_action Action::EVENTS[:right_now_visit_create], current_user, @visit
      if @visit.participant?(current_user) && true?(params[:direct_to_visit])
        cookies.delete :checked_notify
        redirect_to organization_visit_path(@visit.organization, @visit), notice: "Notifications (Email/SMS) Sent"
      else
        cookies[:checked_notify] = true
        redirect_to organization_visits_path(@visit.organization), notice: "Visit Created And Notifications (Email/SMS) Sent"
      end
    else
      render :new
    end
  end

  private

  def visit_params
    attrs = params.require(:visit_order).permit(
      :organization_id,
      patient_id: [],
      provider_ids: [],
      coordinator_ids: [],
    )
    attrs[:provider_ids] = attrs[:provider_ids].delete_if(&:blank?).map(&:to_i)
    attrs[:coordinator_ids] = attrs[:coordinator_ids].delete_if(&:blank?).map(&:to_i)
    attrs[:patient_id] = attrs[:patient_id]&.reject(&:blank?)&.first
    attrs
  end

  def set_org
    @organization = Organization.friendly.find(params[:organization_id])
  end

  def permify_params
    { object: @organization, action: Permission::RIGHT_NOW_VISIT }
  end
end
