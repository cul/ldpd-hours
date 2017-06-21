class UpdateTimeFieldsToString < ActiveRecord::Migration[5.1]
  def change
  	change_column :time_tables, :open, :string
  	change_column :time_tables, :close, :string
  end
end
