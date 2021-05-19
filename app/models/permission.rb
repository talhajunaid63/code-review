# frozen_string_literal: true

class Permission
  attr_accessor :tier, :action

  INDIVIDUAL_TIER_ACTIONS = %i[web_based_platform mobile_platform hd_video]
  PROFESSIONAL_TIER_ACTIONS = INDIVIDUAL_TIER_ACTIONS + %i[recording charge_client marketing_setting]
  PRACTICE_TIER_ACTIONS = PROFESSIONAL_TIER_ACTIONS + %i[easy_connect multi_party_video]
  INTEGRATED_TIER_ACTIONS = PRACTICE_TIER_ACTIONS + %i[system_integration]

  PERMISSION_MATRIX = {
    individual: { actions: INDIVIDUAL_TIER_ACTIONS },
    professional: { actions: PROFESSIONAL_TIER_ACTIONS },
    practice: { actions: PRACTICE_TIER_ACTIONS },
    integrated: { actions: INTEGRATED_TIER_ACTIONS },
    free_full_access: { actions: INTEGRATED_TIER_ACTIONS }
  }

  SYSTEM_INTEGRATION = 'system_integration'
  RIGHT_NOW_VISIT = 'easy_connect'
  INVITATION = 'multi_party_video'
  MARKETING = 'marketing_setting'
  RECORDING = 'recording'

  def initialize(tier, action)
    @tier = tier
    @action = action
  end

  def permitted?
    PERMISSION_MATRIX.with_indifferent_access[tier][:actions].include?(action.to_sym)
  end
end
