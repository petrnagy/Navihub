class DropCookieIdIdOnSessions < ActiveRecord::Migration
  def change
	#remove_column :sessions, :cookie_id_id #already removed :-)
  end
end
