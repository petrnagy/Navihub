class CreateVenueDetailCaches < ActiveRecord::Migration
  def change
    create_table :venue_detail_caches do |t|
      t.string :venue_origin
      t.string :venue_id
      t.text :yield

      t.timestamps
    end
    add_index :venue_detail_caches, [:origin, :id], unique: true
  end
end
