class CreateSitemaps < ActiveRecord::Migration
  def change
    create_table :sitemaps do |t|
      t.string :url
      t.string :controller

      t.timestamps
    end
    add_index :sitemaps, :url, unique: true
    add_index :sitemaps, :controller, unique: false
  end
end
