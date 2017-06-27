class CreatePermissions < ActiveRecord::Migration[5.1]
  def change
    # Add permissions table
    create_table :permissions do |t|
      t.belongs_to :user, index: true
      t.string :action, null: false
      t.string :subject_class, null: false
      t.integer :subject_id
      t.timestamps
    end

    # Remove role from user model
    remove_column :users, :role, :string
  end
end
