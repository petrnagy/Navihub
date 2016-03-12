class RemoveTimestampsFromProviderCredentials < ActiveRecord::Migration
  def change
      remove_column :provider_credentials, :valid_to, :valid_from
  end
end
