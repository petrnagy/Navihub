class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.string :venue_origin
      t.string :venue_id
      t.integer :user_id
      t.text :yield

      t.timestamps
    end
  end
end
