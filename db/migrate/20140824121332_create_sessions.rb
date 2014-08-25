class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :user_id, index: true
      t.references :cookie_id, index: true
      t.string :sessid
      t.timestamp :valid
      t.boolean :remember
      t.boolean :active

      t.timestamps
    end
  end
end
