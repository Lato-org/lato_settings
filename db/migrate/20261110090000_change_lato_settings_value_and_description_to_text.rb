class ChangeLatoSettingsValueAndDescriptionToText < ActiveRecord::Migration[7.1]
  # string columns are limited to 255 chars on PostgreSQL/MySQL, too short for the `text` typology
  def up
    change_column :lato_settings_settings, :value, :text
    change_column :lato_settings_settings, :description, :text
  end

  def down
    change_column :lato_settings_settings, :value, :string
    change_column :lato_settings_settings, :description, :string
  end
end
