class ApplicationConfig
  def self.[](key)
    ENV.fetch(key.to_s, Rails.application.credentials[Rails.env.to_sym][key.to_sym])
  end
end
