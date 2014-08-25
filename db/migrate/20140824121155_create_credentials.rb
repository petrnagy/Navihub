class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :user_id, index: true
      t.string :email
      t.string :password
      t.string :salt
      t.boolean :active

      t.timestamps
    end
  end
end
