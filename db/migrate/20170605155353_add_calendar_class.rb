class AddCalendarClass < ActiveRecord::Migration[5.1]
  def change
    create_table :calendars do |t|
      t.string :code
      t.date :date
      t.string :open
      t.string :close
      t.text :notes
      t.timestamps null: false
    end
  end
end
