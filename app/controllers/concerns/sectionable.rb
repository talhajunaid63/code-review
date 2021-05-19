module Sectionable
  extend ActiveSupport::Concern

  included do
    def section
      self.class.section_name
    end
    helper_method :section
  end

  module ClassMethods
    attr_accessor :section_name

    def section(section="")
      @section_name = section
    end
  end
end
