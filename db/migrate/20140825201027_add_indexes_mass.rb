class AddIndexesMass < ActiveRecord::Migration
  def change
	add_index :cookies, :active
	add_index :credentials, :email, unique: true
	add_index :credentials, :active
	add_index :facebook_sessions, :active
	add_index :twitter_sessions, :active
	add_index :google_sessions, :active
	add_index :locations, :active
	add_index :locations, :latitude
	add_index :locations, :longitude
	add_index :sessions, :active
	add_index :langs, :active
	add_index :vars, :active
  end
end
