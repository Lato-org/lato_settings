Lato.configure do |config|
  config.application_title = 'Lato example app'
  config.application_version = LatoSettings::VERSION

  config.session_root_path = :documentation_path
end

LatoSettings.configure do |config|
end
