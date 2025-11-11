class RemoveProviderAndPasswordTokensFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :provider, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime

    remove_index :users, name: 'index_users_on_uid_and_provider'
  end
end
