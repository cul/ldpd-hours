class RemoveProviderAndPasswordTokensFromUsers < ActiveRecord::Migration[7.1]
  def up
    remove_index :users, name: 'index_users_on_uid_and_provider' if index_exists?(:users, [:uid, :provider], name: 'index_users_on_uid_and_provider')
    
    remove_column :users, :provider, :string if column_exists?(:users, :provider)
    remove_column :users, :reset_password_token, :string if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at, :datetime if column_exists?(:users, :remember_created_at)
  end

  def down
    add_column :users, :provider, :string unless column_exists?(:users, :provider)
    add_column :users, :reset_password_token, :string unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime unless column_exists?(:users, :reset_password_sent_at)
    add_column :users, :remember_created_at, :datetime unless column_exists?(:users, :remember_created_at)
    
    add_index :users, [:uid, :provider], name: 'index_users_on_uid_and_provider' unless index_exists?(:users, [:uid, :provider])
  end
end
