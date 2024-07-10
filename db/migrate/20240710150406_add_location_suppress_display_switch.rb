class AddLocationSuppressDisplaySwitch < ActiveRecord::Migration[6.0]
  def up
    add_column :locations, :suppress_display, :boolean, default: false
  end

  def down
    remove_column :locations, :suppress_display
  end
end
