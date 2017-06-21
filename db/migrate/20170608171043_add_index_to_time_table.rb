class AddIndexToTimeTable < ActiveRecord::Migration[5.1]
  def change
    add_index :time_tables, [:code, :date], :unique => true
  end
end
