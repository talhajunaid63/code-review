class Utils
  class << self
    include ActionView::Helpers::NumberHelper

    def format_phone(phone)
      number_to_phone(phone, area_code: true)
    end

    def format_date_of_birth(dob_m, dob_d, dob_y)
      return if [dob_m, dob_d, dob_y].any? { |e| e.blank? }

      [prepend_zero_to_number(dob_m), prepend_zero_to_number(dob_d), dob_y].join('/')
    end

    def prepend_zero_to_number(number)
      '%02i' % number
    end

    def format_date(date, format='%m/%d/%Y %H:%M %p')
      return if date.blank?

      date.strftime(format)
    end
  end
end
