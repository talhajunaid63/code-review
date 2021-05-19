class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("ADMIN_EMAIL", "admin@uvohealth.com")
  layout 'mailer'
end
