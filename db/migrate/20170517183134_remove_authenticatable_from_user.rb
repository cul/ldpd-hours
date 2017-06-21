class RemoveAuthenticatableFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :email
    remove_column :users, :encrypted_password
  end
end
