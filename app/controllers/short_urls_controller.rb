class ShortUrlsController < ApplicationController
  skip_before_action :restrict_demo_user

  def visit
    visit = Visit.unscoped.find(params[:visit_id])
    redirect_to organization_visit_path visit.organization, visit
  end

  def new_visit
    if current_user && current_user.patient?
      log_action Action::EVENTS[:setup_new_wi_visit], current_user, nil, {url: request.path}
      redirect_to new_wi_organization_visits_path(current_user.organization)
    else
      redirect_to main_route
    end
  end
end
