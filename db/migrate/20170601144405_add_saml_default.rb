class AddSamlDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :provider, "saml"
  end
end
