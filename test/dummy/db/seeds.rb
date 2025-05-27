
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

LatoSettings::Setting.create!(
  key: 'number',
  value: 1.12,
  label: "Number",
  description: "A number setting",
  required: true,
  typology: :number,
  options: { min: 0, max: 100, step: 0.01 }
)

LatoSettings::Setting.create!(
  key: 'date',
  value: '2023-10-01',
  label: "Date",
  description: "A date setting",
  required: true,
  typology: :date,
  options: { min: '2023-01-01', max: '2023-12-31' }
)

LatoSettings::Setting.create!(
  key: 'select',
  value: 'option1',
  label: "Select",
  description: "A select setting",
  required: true,
  typology: :select,
  options: { values: ['option1', 'option2', 'option3'] }
)

LatoSettings::Setting.create!(
  key: 'integer',
  value: 42,
  label: "Integer",
  description: "An integer setting",
  required: true,
  typology: :integer,
  options: { min: 0, max: 100, step: 1 }
)