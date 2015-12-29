class AddIndexes < ActiveRecord::Migration
  def change
    add_index :favorites, :user_id, unique: false
    add_index :facebook_sessions, :valid_to, unique: false
    add_index :google_sessions, :valid_to, unique: false
    add_index :reverse_geocode_caches, :updated_at, unique: false
    add_index :ipinfo_caches, :updated_at, unique: false
    add_index :permalinks, :user_id, unique: false
  end
end
