class CreateGeocodeCache < ActiveRecord::Migration
  def change
    create_table :geocode_caches do |t|
      t.string :addr
      t.float :latitude
      t.float :longitude
      t.timestamps
    end
    add_index :geocode_caches, :addr, unique: true
  end
end
