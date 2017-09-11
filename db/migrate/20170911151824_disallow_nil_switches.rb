class DisallowNilSwitches < ActiveRecord::Migration[5.1]
  def change
    change_column :timetables, :closed, :boolean, default: false, null: false
    change_column :timetables, :tbd, :boolean, default: false, null: false
  end
end
