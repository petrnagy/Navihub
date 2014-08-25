class CreateGoogleSessions < ActiveRecord::Migration
  def change
    create_table :google_sessions do |t|
      t.references :user_id, index: true
      t.timestamp :valid
      t.timestamp :expires
      t.timestamp :issued
      t.text :token_json
      t.binary :info_ser
      t.boolean :active

      t.timestamps
    end
  end
end
