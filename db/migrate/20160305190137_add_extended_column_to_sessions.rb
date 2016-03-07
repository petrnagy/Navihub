class AddExtendedColumnToSessions < ActiveRecord::Migration
  def change
      add_column :login_sessions, :extended, :boolean
  end
end
