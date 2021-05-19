class OrgSetups::OrgSetupsController < ApplicationController
  before_action :ensure_logged_out

  def new
    @plans = Organization::Plan.order(:display_order)
    @features = Organization::Feature.order(:created_at)
    @org_setup = OrgSetup.new
  end
end
