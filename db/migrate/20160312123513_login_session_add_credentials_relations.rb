class LoginSessionAddCredentialsRelations < ActiveRecord::Migration
  def change
      add_column :login_sessions, :credential_id, :integer
      add_column :login_sessions, :provider_credential_id, :integer
  end
end
