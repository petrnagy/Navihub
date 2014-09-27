class ApiCacheAddCols < ActiveRecord::Migration
  def change
	add_column :api_caches, :key, :string
	add_index :api_caches, :key, unique: true
	add_column :api_caches, :data, :text
  end
end
