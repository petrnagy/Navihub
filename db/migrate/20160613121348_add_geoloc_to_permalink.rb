class AddGeolocToPermalink < ActiveRecord::Migration
  def change
      add_column :permalinks, :ll, :string
  end
end
