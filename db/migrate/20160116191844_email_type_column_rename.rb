class EmailTypeColumnRename < ActiveRecord::Migration
  def change
    rename_column :emails, :type, :email_type
  end
end
