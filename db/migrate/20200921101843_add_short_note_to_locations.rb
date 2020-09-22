class AddShortNoteToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :short_note, :string
    add_column :locations, :short_note_url, :text
  end
end
