class AddFieldsToTimeTables < ActiveRecord::Migration[5.1]
  def change
    add_column :time_tables, :tbd, :boolean, default: false
    add_column :time_tables, :closed, :boolean, default: false
    add_column :time_tables, :note, :string 
    remove_index :time_tables, column: [:code, :date]
    remove_column :time_tables, :code
    add_reference :time_tables, :library, index: true, foreign_key: true, type: :bigint
    add_index :time_tables, [:library_id, :date], :unique => true
    rename_table :time_tables, :timetables
  end
end
