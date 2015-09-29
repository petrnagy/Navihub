class AddIndexToPermalinksId < ActiveRecord::Migration
  def change
      add_index :permalinks, :permalink_id
  end
end
