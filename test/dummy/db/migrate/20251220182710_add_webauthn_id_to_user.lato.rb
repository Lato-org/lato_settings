# This migration comes from lato (originally 20251206170443)
class AddWebauthnIdToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :lato_users, :webauthn_id, :string
    add_column :lato_users, :webauthn_public_key, :text
  end
end
