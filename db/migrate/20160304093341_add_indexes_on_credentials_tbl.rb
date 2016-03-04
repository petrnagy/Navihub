class AddIndexesOnCredentialsTbl < ActiveRecord::Migration
  def change
      add_index :credentials, :username, unique: true
      add_index :credentials, :password, unique: false
      add_index :credentials, :salt, unique: false
  end
end
