class FrontpageLocationsAndIndex < ActiveRecord::Migration[5.1]
  def change
    change_table :locations do |t|
      t.boolean :front_page, null: false, default: false
      t.index :front_page
      t.index :code
    end
  end
end
