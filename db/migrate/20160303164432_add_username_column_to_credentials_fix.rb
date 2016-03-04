class AddUsernameColumnToCredentialsFix < ActiveRecord::Migration
  def change
      add_column :credentials, :username, :string
      remove_column :users, :username
  end
end
