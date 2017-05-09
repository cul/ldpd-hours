class CreateLibraries < ActiveRecord::Migration[5.1]
  def change
    create_table :libraries do |t|
      t.string :name, null: false, unique: true
      t.string :code, null: false, unique: true
      t.string :url
      t.text :comment
      t.text :comment_two
      t.string :summary

      t.timestamps
    end
  end
end
