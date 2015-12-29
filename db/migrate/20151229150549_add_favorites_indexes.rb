class AddFavoritesIndexes < ActiveRecord::Migration
  def change
    add_index :favorites, :user_id, unique: false
  end
end
