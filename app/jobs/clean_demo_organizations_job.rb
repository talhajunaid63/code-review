class CleanDemoOrganizationsJob < ApplicationJob
  def perform
    Organization.demo_orgs.where('created_at <= ?', Visit::DEMO_VISIT_DURATION.ago).find_each do |organization|
      Rails.logger.info("Deleting Demo Organization ID: #{organization.id}")

      organization.destroy
    rescue StandardError => e
      Rails.logger.info("Error Occurred: #{e.message} for #{organization.id}")
    end
  end
end
