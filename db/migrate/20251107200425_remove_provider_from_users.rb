class RemoveProviderFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :provider, :string
    remove_index :users, name: 'index_users_on_uid_and_provider'
  end
end
