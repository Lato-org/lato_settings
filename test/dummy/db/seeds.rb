
puts 'Creating default admin user...'
Lato::User.find_or_create_by!(email: 'admin@mail.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'Admin'
  user.password = 'Password1!'
  user.password_confirmation = 'Password1!'
  user.accepted_privacy_policy_version = 1
  user.accepted_terms_and_conditions_version = 1
  user.lato_settings_admin = true
end
puts 'Default lato user created successfully!'

LatoSettings::Setting.find_or_create_by!(key: 'site_name') do |setting|
  setting.value = "Lato Settings Example"
  setting.label = "Site name"
  setting.description = "The name of the site"
  setting.required = true
end

LatoSettings::Setting.find_or_create_by!(key: 'number') do |setting|
  setting.value = 1.12
  setting.label = "Number"
  setting.description = "A number setting"
  setting.required = true
  setting.typology = :number
  setting.options = { min: 0, max: 100, step: 0.01 }
end

LatoSettings::Setting.find_or_create_by!(key: 'date') do |setting|
  setting.value = '2023-10-01'
  setting.label = "Date"
  setting.description = "A date setting"
  setting.required = true
  setting.typology = :date
  setting.options = { min: '2023-01-01', max: '2023-12-31' }
end

LatoSettings::Setting.find_or_create_by!(key: 'select') do |setting|
  setting.value = 'option1'
  setting.label = "Select"
  setting.description = "A select setting"
  setting.required = true
  setting.typology = :select
  setting.options = { values: ['option1', 'option2', 'option3'] }
end

LatoSettings::Setting.find_or_create_by!(key: 'integer') do |setting|
  setting.value = 42
  setting.label = "Integer"
  setting.description = "An integer setting"
  setting.required = true
  setting.typology = :integer
  setting.options = { min: 0, max: 100, step: 1 }
end