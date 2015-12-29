class CreateReverseGeocodeCaches < ActiveRecord::Migration
  def change
    create_table :reverse_geocode_caches do |t|
      t.float :latitude
      t.float :longitude
      t.string :addr

      t.timestamps
    end
    add_index :geocode_caches, [:latitude, :longitude], unique: true
  end
end
