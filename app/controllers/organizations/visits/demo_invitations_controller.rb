class Organizations::Visits::DemoInvitationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_visit
  before_action :ensure_invitation_permissions
  skip_before_action :restrict_demo_user

  include PermissionConcern

  def new
    @demo_invitation = Organization::Visit::DemoInvitation.new
    @participants_count = @visit.participants_count
  end

  def create
    @demo_invitation = Organization::Visit::DemoInvitation.new(demo_invitation_params)

    if @demo_invitation.process
      flash.now[:notice] = 'Invitation Successfully Sent.'
    else
      flash.now[:alert] = "Could not Send Invitation because #{@demo_invitation.errors.full_messages.to_sentence}"
    end
  end

  private

  def demo_invitation_params
    params.require(:organization_visit_demo_invitation).permit(:visit_id, :patient, :providers, :coordinators)
  end

  def set_visit
    @visit = Visit.unscoped.find params[:visit_id]
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
