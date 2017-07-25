class UpdateToPermissions < ActiveRecord::Migration[5.1]
  def change
    rename_column :permissions, :action, :role
    change_column :permissions, :subject_class, :string, null: true
  end
end
