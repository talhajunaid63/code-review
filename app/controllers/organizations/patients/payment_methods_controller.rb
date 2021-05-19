class Organizations::Patients::PaymentMethodsController < ApplicationController
  before_action :set_org
  before_action :set_user, only: [:index, :create]

  def index
    @user.ensure_payment_method
  end

  def create
    response = StripeCardService.new(@user, payment_method_params[:stripe_card_id]).process

    if response.success?
      flash[:notice] = response.message
      return redirect_to organization_visit_path(@organization, params[:visit_id]) if params[:visit_id].present?

      redirect_back(fallback_location: @user.route) if params[:visit_id].blank?
    else
      flash.now[:alert] = response.message
      render :index
    end
  end

  private

  def set_org
    if params[:organization_id]
      @organization = Organization.friendly.find(params[:organization_id])
    end
  end

  def payment_method_params
    params.require(:payment_method).permit(:stripe_card_id)
  end

  def set_user
    @user = Patient.find(params.require(:patient_id))
  end
end
