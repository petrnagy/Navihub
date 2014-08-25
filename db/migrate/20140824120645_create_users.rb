class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :id_fb
      t.string :id_tw
      t.string :id_gp
      t.string :name
      t.string :imgurl
      t.boolean :active

      t.timestamps
    end
  end
end
