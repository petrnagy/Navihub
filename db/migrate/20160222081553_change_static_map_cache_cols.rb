class ChangeStaticMapCacheCols < ActiveRecord::Migration
  def change
      change_column :google_static_map_caches, :url, :string, :limit => 1000
  end
end
