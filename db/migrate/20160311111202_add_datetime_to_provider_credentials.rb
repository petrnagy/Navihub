class AddDatetimeToProviderCredentials < ActiveRecord::Migration
  def change
      add_column :provider_credentials, :valid_to, :datetime
  end
end
