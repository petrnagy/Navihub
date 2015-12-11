class AddLockColumnToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :lock, :boolean
  end
end
