class ChangeLibraryTableName < ActiveRecord::Migration[5.1]
  def change
    remove_index :timetables, name: :index_timetables_on_library_id_and_date
    remove_reference :timetables, :library, index: true, foreign_key: true
    rename_table :libraries, :locations
    add_reference :timetables, :location, index: true, foreign_key: true
    add_index :timetables, [:location_id, :date], :unique => true
  end
end
