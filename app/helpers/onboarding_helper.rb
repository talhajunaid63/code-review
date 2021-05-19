module OnboardingHelper

  def onboarding_progress_number(completed_steps, total_steps)
    (completed_steps.to_i * 100) / total_steps
  end

end
