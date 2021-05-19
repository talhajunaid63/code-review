module ServiceAreaStates
  extend ActiveSupport::Concern

  def secondary_states
    service_area_states.where(is_primary: false)
  end

  def primary_state
    service_area_states.where(is_primary: true).first
  end

  def update_primary_state(primary_state_id)
    return if primary_state_id.blank?

    states.destroy(primary_state.state) if primary_state.present?
    service_area_states.create(state_id: primary_state_id, is_primary: true)
  end
end
