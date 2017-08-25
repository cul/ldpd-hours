class IndexTimetables < ActiveRecord::Migration[5.1]
  def change
    change_table :timetables do |t|
      t.index :date
      t.index :open
      t.index :close
    end
  end
end
