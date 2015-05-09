class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :type
      t.string :name
      t.string :email
      t.text :text
      t.string :hash
      t.text :data

      t.timestamps
    end
    add_index :forms, :hash, unique: true
  end
end
