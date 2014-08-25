class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :get
      t.string :set
      t.string :delete
      t.references :user_id, index: true
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :country
      t.string :country_short
      t.string :city
      t.string :city2
      t.string :street1
      t.string :street2
      t.boolean :active

      t.timestamps
    end
  end
end
