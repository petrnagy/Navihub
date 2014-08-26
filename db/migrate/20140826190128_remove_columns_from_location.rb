class RemoveColumnsFromLocation < ActiveRecord::Migration
  def change
	remove_column :locations, :get
	remove_column :locations, :set
	remove_column :locations, :delete
	rename_column :locations, :user_id_id, :user_id
	remove_column :locations, :name
  end
end
