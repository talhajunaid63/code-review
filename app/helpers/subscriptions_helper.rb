module SubscriptionsHelper

  def plan_price_details(plan)
    html_details = "<h4 class=\"text-faded\">"
    if plan.by_quote
      html_details << "By Quote"
    elsif plan.special
      html_details << plan.name
    elsif plan.price.zero?
      html_details << "Free"
    else
      html_details << number_to_currency(plan.price, precision: 0)
      html_details << "/#{plan.interval[0..1]}"
      html_details << "<br><span class='white'><small>Per User</small></span>"
    end
    html_details << "</h4>"
    html_details.html_safe
  end

  def plan_price_details_for_cards(plan)
    html_details = "<h4 class=\"text-faded\">"
    if plan.by_quote
      html_details << "By Quote"
    elsif plan.special
      html_details << plan.name
    elsif plan.price.zero?
      html_details << "Free"
    else
      html_details << number_to_currency(plan.price, precision: 0)
      html_details << "/#{plan.interval[0..1]}"
      html_details << "<br><span class='black'><small>Per User</small></span>"
    end
    html_details << "</h4>"
    html_details.html_safe
  end

  def included_in_plan(title, description)
    "<p>
      <i class='fa fa-check green' aria-hidden='true'></i> #{title}<br>
      <small class='text-muted'> #{description} </small>
    </p>".html_safe
  end

  def unincluded_in_plan(title, description)
    "<p>
      <i class='fa fa-times red' aria-hidden='true'></i> #{title} <br>
      <small class='text-muted'> #{description} </small>
    </p>".html_safe
  end

  def membership_plan_detail(plan, feature)
    if plan.includes_feature? feature.id
      included_feature = plan.included_features.where(organization_feature_id: feature.id).first
      return included_in_plan(feature.name, feature.description)
    end
    unincluded_in_plan(feature.name, feature.description)
  end

end
