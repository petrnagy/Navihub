class RenameValidColumnsToValidTo < ActiveRecord::Migration
  def change
	rename_column :sessions, :valid, :valid_to
	rename_column :facebook_sessions, :valid, :valid_to
	rename_column :twitter_sessions, :valid, :valid_to
	rename_column :google_sessions, :valid, :valid_to
  end
end
