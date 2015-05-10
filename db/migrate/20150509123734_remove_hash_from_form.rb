class RemoveHashFromForm < ActiveRecord::Migration
  def change
    remove_column :forms, :hash, :string
  end
end
