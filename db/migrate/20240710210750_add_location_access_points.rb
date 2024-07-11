class AddLocationAccessPoints < ActiveRecord::Migration[6.0]
  def change
    create_table :access_points do |t|
      t.integer :client_count
      t.timestamps null: false
    end
    create_table :access_points_locations do |t|
      t.timestamps null: false
      t.bigint :location_id, null: false
      t.bigint :access_point_id, null: false
      t.index :location_id
      t.index :access_point_id
      t.index [:location_id, :access_point_id], unique: true
    end
    add_column :locations, :wifi_connections_baseline, :int, null: true
  end
end
