class CreateFacebookSessions < ActiveRecord::Migration
  def change
    create_table :facebook_sessions do |t|
      t.references :user_id, index: true
      t.timestamp :valid
      t.timestamp :expires
      t.timestamp :issued
      t.binary :session_ser
      t.binary :info_ser
      t.boolean :active

      t.timestamps
    end
  end
end
