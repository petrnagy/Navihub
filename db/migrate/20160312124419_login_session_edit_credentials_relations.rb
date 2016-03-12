class LoginSessionEditCredentialsRelations < ActiveRecord::Migration
  def change
      remove_column :login_sessions, :credential_id
      remove_column :login_sessions, :provider_credential_id
      add_column :login_sessions, :credentials_id, :integer
      add_column :login_sessions, :provider_credentials_id, :integer
  end
end
