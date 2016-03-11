class AddSessionIdAndCookieIdToProviderCredentials < ActiveRecord::Migration
  def change
      add_column :provider_credentials, :session_id, :integer
      add_column :provider_credentials, :cookie_id, :integer
  end
end
