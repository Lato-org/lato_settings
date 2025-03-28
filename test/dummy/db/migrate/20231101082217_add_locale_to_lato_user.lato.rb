# This migration comes from lato (originally 20221229233844)
class AddLocaleToLatoUser < ActiveRecord::Migration[7.0]
  def change
    add_column :lato_users, :locale, :string
  end
end
