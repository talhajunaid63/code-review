# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview

  def contact_us
    params = {email: "john@fake.com", name: "John Doe", company: "Acme, inc.", phone: "555-555-5555", message: "This is a test message just to see if this thing is working properly."}
    ContactMailer.contact_us(params)
  end

  def contact_us_autoresponder
    params = {email: "john@fake.com", name: "John Doe", company: "Acme, inc.", phone: "555-555-5555", message: "This is a test message just to see if this thing is working properly."}
    ContactMailer.contact_us_autoresponder(params)
  end

end
