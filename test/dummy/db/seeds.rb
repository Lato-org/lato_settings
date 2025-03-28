
puts 'Creating default admin user...'
Lato::User.create!(
  first_name: 'Admin',
  last_name: 'Admin',
  email: 'admin@mail.com',
  password: 'Password1!',
  password_confirmation: 'Password1!',
  accepted_privacy_policy_version: 1,
  accepted_terms_and_conditions_version: 1,
  lato_settings_admin: true
)
puts 'Default lato user created successfully!'

LatoSettings::Setting.create!(
  key: 'site_name',
  value: "Lato Settings Example",
  label: "Site name",
  description: "The name of the site",
  required: true
)