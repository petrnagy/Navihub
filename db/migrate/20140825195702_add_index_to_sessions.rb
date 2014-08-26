class AddIndexToSessions < ActiveRecord::Migration
  def change
    #add_column :sessions, :sessid, :string
    add_index :sessions, :sessid, unique: true
  end
end
