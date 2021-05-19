class OrgSetups::ProvidersController < ApplicationController
  before_action :set_org_setup, :set_organization
  before_action :set_providers, only: %i[new create]

  def new
    @provider = Provider.new(organization_id: @organization.id)
    @provider.build_provider_detail
  end

  def create
    if params[:finish]
      @org_setup.update_column(:step, 5)
      redirect_to OrganizationOnboardingService.new(@org_setup).next_step
      return
    end

    @provider = Provider.new(provider_params)
    @provider.organization_id ||= @organization.id
    if @provider.save
      @provider.update_primary_state(@organization.primary_state&.state_id)

      redirect_to new_org_setup_provider_path(@org_setup), notice: "Provider Added"
    else
      flash.now[:alert] = @provider.errors.full_messages.first
      render :new
    end
  end

  private

  def provider_params
    params.require(:provider).permit(:phone, :email, :password, :first_name, :last_name, :password_confirmation, :organization_id, :time_zone, {:provider_detail_attributes => [:name, :provider_id, :acts_as_org_admin]})
  end

  def set_org_setup
    @org_setup = OrgSetup.find(params[:org_setup_id])
  end

  def set_organization
    @organization = @org_setup.organization
  end

  def set_providers
    @providers =
      FindProvidersQuery
      .new(@organization.providers)
      .call(organization_id: @organization.id)
      .page(params[:page]).per(Provider::PER_PAGE)
  end
end
