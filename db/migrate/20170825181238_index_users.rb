class IndexUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.index :uid
      t.index [:uid, :provider]
    end
  end
end
