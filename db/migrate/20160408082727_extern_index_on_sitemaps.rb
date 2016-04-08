class ExternIndexOnSitemaps < ActiveRecord::Migration
  def change
      remove_index :sitemaps, :name => 'index_sitemaps_on_url'
      add_index :sitemaps, [:url, :page_title], unique: true
  end
end
