class FixGeocachesIndexes < ActiveRecord::Migration
  def change
    remove_index :geocode_caches, :name => 'index_geocode_caches_on_latitude_and_longitude'
    add_index :geocode_caches, [:latitude, :longitude], unique: false
    add_index :reverse_geocode_caches, [:addr], unique: false
    add_index :reverse_geocode_caches, [:latitude, :longitude], unique: true
  end
end
