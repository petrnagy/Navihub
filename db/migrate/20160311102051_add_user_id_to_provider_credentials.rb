class AddUserIdToProviderCredentials < ActiveRecord::Migration
  def change
      add_column :provider_credentials, :user_id, :integer
  end
end
