class AddKeyToForm < ActiveRecord::Migration
  def change
    add_column :forms, :key, :string
    add_index :forms, :key, unique: true
  end
end
