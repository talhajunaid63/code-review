# Preview all emails at http://localhost:3000/rails/mailers/patient_notifier_mailer
class PatientNotifierMailerPreview < ActionMailer::Preview

  def welcome
    PatientNotifierMailer.send_welcome_email(Patientfirst)
  end

  def reciept
    @visit = Visit.all_completed.last
    @user = Patient.find(@visit.patient_id)
    PatientNotifierMailer.send_reciept(@user, @visit.id)
  end


  def send_login
    @patient = Patientfirst
    @password = "DL4564"
    PatientNotifierMailer.send_login(@patient, @password)
  end

  def send_visit_reminder
    @patient = Patientfirst
    @visit = Visit.first
    PatientNotifierMailer.send_visit_reminder(@patient, @visit)
  end

  def nofity_searching_providers_process
    @patient = Patientfirst
    @visit = Visit.first
    PatientNotifierMailer.nofity_searching_providers_process(@patient, @visit)
  end

  def nofity_a_provider_is_ready
    @patient = Patientfirst
    @visit = Visit.first
    PatientNotifierMailer.nofity_a_provider_is_ready(@patient, @visit)
  end  

  def nofity_no_providers_available
    @patient = Patientfirst
    @visit = Visit.first
    PatientNotifierMailer.nofity_no_providers_available(@patient, @visit)
  end  

end
