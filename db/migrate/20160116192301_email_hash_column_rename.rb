class EmailHashColumnRename < ActiveRecord::Migration
  def change
    rename_column :emails, :hash, :email_hash
  end
end
