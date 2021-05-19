class Organizations::Visits::InvitationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_visit
  before_action :ensure_invitation_permissions

  include PermissionConcern

  def new
    @invitation = Organization::Visit::Invitation.new
    @participants_count = @visit.participants_count
  end

  def create
    @invitation = Organization::Visit::Invitation.new(invitation_params)
    if @invitation.process
      flash.now[:notice] = 'Invitation Successfully Sent.'
    else
      flash.now[:alert] = "Could not Send Invitation because #{@invitation.errors.full_messages.to_sentence}"
    end
  end

  private

  def invitation_params
    attrs = params.require(:organization_visit_invitation).permit(
      :visit_id,
      provider_ids: [],
      coordinator_ids: [],
    )

    attrs[:provider_ids] = attrs[:provider_ids].reject(&:blank?).map(&:to_i)
    attrs[:coordinator_ids] = attrs[:coordinator_ids].reject(&:blank?).map(&:to_i)
    attrs
  end

  def set_visit
    @visit = Visit.find params[:visit_id]
  end

  def ensure_invitation_permissions
    unless policy(@visit).invite?
      flash.now[:alert] = 'You are un-authorized to perform this action.'
      return render 'organizations/visits/invitations/error'
    end
  end

  def permify_params
    { object: @visit.organization, action: Permission::INVITATION }
  end
end
