class CreateLatoSettingsSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :lato_settings_settings do |t|
      t.string :key, null: false, index: { unique: true }
      t.integer :typology, default: 0
      t.string :value
      t.string :label
      t.string :description
      t.boolean :required, default: false
      t.json :options
      t.timestamps
    end
  end
end
