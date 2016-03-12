class AddActiveFlagToProviderCredentials < ActiveRecord::Migration
  def change
      add_column :provider_credentials, :active, :boolean
  end
end
