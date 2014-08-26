class AddIndexToUsers < ActiveRecord::Migration
  def change
    #add_column :users, :id_fb, :string
	add_index :users, :id_fb
	add_index :users, :id_tw
	add_index :users, :id_gp
	add_index :users, :active
  end
end
