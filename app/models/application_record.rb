class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def error_message
    self.errors.full_messages.to_sentence
  end
end
