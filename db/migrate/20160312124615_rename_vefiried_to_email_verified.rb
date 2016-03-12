class RenameVefiriedToEmailVerified < ActiveRecord::Migration
  def change
      rename_column :credentials, :verified, :email_verified
  end
end
