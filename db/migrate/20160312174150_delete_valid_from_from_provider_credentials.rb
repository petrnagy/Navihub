class DeleteValidFromFromProviderCredentials < ActiveRecord::Migration
  def change
      remove_column :provider_credentials, :valid_from
  end
end
