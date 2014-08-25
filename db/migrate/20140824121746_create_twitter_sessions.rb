class CreateTwitterSessions < ActiveRecord::Migration
  def change
    create_table :twitter_sessions do |t|
      t.references :user_id, index: true
      t.string :token
      t.string :token_secret
      t.timestamp :valid
      t.binary :conn_ser
      t.binary :credentials_ser
      t.boolean :active

      t.timestamps
    end
  end
end
