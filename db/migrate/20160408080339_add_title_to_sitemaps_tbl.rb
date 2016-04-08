class AddTitleToSitemapsTbl < ActiveRecord::Migration
  def change
      add_column :sitemaps, :page_title, :string
  end
end
