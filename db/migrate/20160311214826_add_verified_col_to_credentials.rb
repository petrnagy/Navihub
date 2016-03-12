class AddVerifiedColToCredentials < ActiveRecord::Migration
  def change
      add_column :credentials, :verified, :boolean
  end
end
