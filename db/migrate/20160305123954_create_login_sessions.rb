class CreateLoginSessions < ActiveRecord::Migration
  def change
    create_table :login_sessions do |t|
      t.references :user, index: true
      t.references :cookie, index: true
      t.references :session, index: true
      t.datetime :valid_from
      t.datetime :valid_to

      t.timestamps
    end
  end
end
