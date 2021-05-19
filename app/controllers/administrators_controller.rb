class AdministratorsController < ApplicationController

  def new
    @administrator = Administrator.new
  end

  def show
    @administrator = Administrator.find(params[:id])
  end

  def index
    @administrators = Administrator.all
  end

  def manage
    @administrators = Administrator.all
  end

  def create
    if params[:password] == ApplicationConfig['MASTERADMIN']
      @administrator = Administrator.new(administrator_params)
      if @administrator.save!
        redirect_to '/', notice: 'Administrator Created'
      else
        redirect_back fallback_location: current_user.route, alert: 'Something is wrong'
      end
    else
      redirect_back fallback_location: current_user.route, alert: 'Administrative password incorrect.'
    end
  end

  def update
    @administrator = Administrator.find(params[:id])
    if @administrator.update_attributes(administrator_params)
      redirect_back fallback_location: current_user.route, notice: 'Provider Updated'
    else
      redirect_back fallback_location: current_user.route, alert: 'Something is wrong'
    end
  end

  def edit
    @administrator = Administrator.find(params[:id])
    @administrator.build_provider_detail unless @administrator.provider_detail
  end


  private
  def administrator_params
    params.require(:administrator).permit(:avatar, :phone, :email, :password, :first_name, :last_name, :password_confirmation, :source, :zip, {:provider_detail_attributes => [:qualifications, :about, :specialties, :city, :state, :provider_id]})
  end

end
