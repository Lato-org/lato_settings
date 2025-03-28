# This migration comes from lato (originally 20240222171418)
class AddIndexesOnLatoUsersEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :lato_users, :email, unique: true
  end
end
