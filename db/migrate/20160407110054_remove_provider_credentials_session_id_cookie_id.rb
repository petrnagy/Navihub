class RemoveProviderCredentialsSessionIdCookieId < ActiveRecord::Migration
  def change
      remove_column :provider_credentials, :session_id
      remove_column :provider_credentials, :cookie_id
  end
end
