class CreateCookies < ActiveRecord::Migration
  def change
    create_table :cookies do |t|
      t.references :user_id, index: true
      t.string :cookie
      t.boolean :active

      t.timestamps
    end
  end
end
