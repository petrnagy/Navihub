class AddIndexToCookies < ActiveRecord::Migration
  def change
    #add_column :cookies, :cookie, :string
    add_index :cookies, :cookie, unique: true
  end
end
