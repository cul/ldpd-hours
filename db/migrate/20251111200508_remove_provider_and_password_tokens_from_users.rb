class RemoveProviderAndPasswordTokensFromUsers < ActiveRecord::Migration[7.1]
  def up
    remove_index :users, name: 'index_users_on_uid_and_provider'
    
    remove_column :users, :provider, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
  end

  def down
    add_column :users, :provider, :string
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime
    
    add_index :users, [:uid, :provider], name: 'index_users_on_uid_and_provider'
  end
end
