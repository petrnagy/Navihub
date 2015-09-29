class CreatePermalinks < ActiveRecord::Migration
  def change
    create_table :permalinks do |t|
      t.string :venue_origin
      t.string :venue_id
      t.text :yield

      t.timestamps
    end
  end
end
