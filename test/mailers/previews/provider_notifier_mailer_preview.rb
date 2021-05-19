# Preview all emails at http://localhost:3000/rails/mailers/patient_notifier_mailer
class ProviderNotifierMailerPreview < ActionMailer::Preview
  def send_visit_reminder
    @provider = Provider.first
    @visit = Visit.first
    ProviderNotifierMailer.send_visit_reminder(@provider, @visit)
  end

end
