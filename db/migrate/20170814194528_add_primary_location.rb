class AddPrimaryLocation < ActiveRecord::Migration[5.1]
  def up
    add_reference :locations, :primary_location, foreign_key: {to_table: :locations}
    add_column :locations, :primary, :boolean, default: false
    add_index :locations, :primary
  end

  def down
    remove_index :locations, :primary
    remove_column :locations, :primary
    remove_reference :locations, :primary_location
  end
end
