class DropSocialTables < ActiveRecord::Migration
  def change
      drop_table :facebook_sessions
      drop_table :google_sessions
      drop_table :twitter_sessions
  end
end
