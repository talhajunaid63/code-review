class Emails::ContactUsController < ApplicationController
  invisible_captcha only: [:create]


  def create
    # check to see if the name field contains a number.
    if contact_us_params[:name].count("0-9") == 0
      ContactMailer.contact_us(contact_us_params).deliver_later
      ContactMailer.contact_us_autoresponder(contact_us_params).deliver_later
      redirect_back(fallback_location: root_path, notice: notice_text)
    # If it does contain a number don't send the message.
    else
      redirect_back(fallback_location: root_path, notice: notice_text)
    end
  end

  def admin_assistance
    ContactMailer.contact_us_for_assistance(admin_assistance_params).deliver_later
    redirect_back(fallback_location: root_path, notice: 'Thank you, we will be in touch shortly.')
  end

  private

  def contact_us_params
    params.require(:contact_us).permit(:email, :name, :phone, :company, :message).to_h
  end

  def admin_assistance_params
    params.require(:admin_help).permit(:email, :message).to_h
  end

  def notice_text
    if current_user && current_user.type == "OrgAdmin"
      return_to_text = "Return to Settings page"
      return_to = current_user.route
    else
      return_to_text = "Return to main page"
      return_to = session[:return_to] || root_path
    end
    %Q[Thank you, we'll be in touch shortly <a href="#{return_to}" class="pull-right mr-5">#{return_to_text}</a>]
  end

end
