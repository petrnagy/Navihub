class AddValidFromToProviderCredentials < ActiveRecord::Migration
  def change
      add_column :provider_credentials, :valid_from, :datetime
  end
end
