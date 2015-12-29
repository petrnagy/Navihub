class AddIpinfoColumns < ActiveRecord::Migration
  def change
    add_column :ipinfo_caches, :ipv4, :string
    add_column :ipinfo_caches, :latitude, :float
    add_column :ipinfo_caches, :longitude, :float

    add_index :ipinfo_caches, :ipv4, unique: true
  end
end
