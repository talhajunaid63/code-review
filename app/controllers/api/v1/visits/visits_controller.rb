class Api::V1::Visits::VisitsController < ApiController
  #TODO refactor to require app_token
  #before_filter :authorize_app, except: [:cable, :show, :index]
  before_action :authorize_app, except: [:broadcast, :update]
  before_action :auth_user, except: [:broadcast, :update]
  before_action :set_visit, only: [:show, :update]
  before_action :set_open_tok_data, only: [:show]

  def index
    if @user.respond_to?(:visits)
      scope = @user.coordinator? ? Visit.by_coordinators(@user.id) : @user.visits
      @visits = scope.includes(:consent_users, :patient).all_confirmed.order(schedule: :asc)
    else
      api_return('Given auth_token does not reference a user having a visits association.', '404')
    end
  end

  def show
  end


  def create
    visit = Visit.new(visit_params)
    visit.organization = @authenticated_organization || @user.organization
    visit.patient_id = @user.id if @user.type == 'Patient'
    if visit.save
      api_return('Visit Created','200')
    else
      throw_400(visit.errors.full_messages.to_sentence)
    end
  end

  def update
    @user = return_user_from_auth_token
    if @user
      set_peer_connection_data
      @visit.request_auth_token = @user.authentication_token
      @visit.update(visit_params)
      @organization = @visit.organization
      @patient = @visit.patient
       api_return('Visit Updated','200')
    else
      throw_500(@message ? @message : 'A user for given auth_token not found')
    end
  end

  private

  def visit_params
    params.permit(
      :patient_id,
      :dependent_id,
      :provider_id,
      :schedule,
      :status,
      :patient_notes,
      :provider_notes,
      :start_date_time,
      :end_date_time,
      :stripe_invoice,
      :internal_notes,
      :consent_collected_by,
      :consent_collected_on,
    )
  end

  def set_visit
    @visit = Visit.find(params[:id])
  end

  def set_open_tok_data
    @open_tok_data = {
      apikey: ApplicationConfig["TOK_API_VP8"],
      tok_token: TokBoxService.new(@visit).generate_token
    }
  end

  def set_peer_connection_data
    if params[:peer_connection_data]
      @visit.peer_connection_data = params[:peer_connection_data]
    end
  end

end
