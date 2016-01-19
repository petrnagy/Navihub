class CreateGoogleStaticMapCaches < ActiveRecord::Migration
  def change
    create_table :google_static_map_caches do |t|
      t.string :url
      t.boolean :found
      t.string :x_staticmap_api_warning

      t.timestamps
    end
    add_index :google_static_map_caches, [:url], unique: true
    add_index :google_static_map_caches, [:found], unique: false
  end
end
