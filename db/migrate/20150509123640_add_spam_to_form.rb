class AddSpamToForm < ActiveRecord::Migration
  def change
    add_column :forms, :spam, :boolean
  end
end
