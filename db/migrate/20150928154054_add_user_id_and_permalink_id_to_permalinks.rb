class AddUserIdAndPermalinkIdToPermalinks < ActiveRecord::Migration
  def change
    add_column :permalinks, :user_id, :integer
    add_column :permalinks, :permalink_id, :string
  end
end
