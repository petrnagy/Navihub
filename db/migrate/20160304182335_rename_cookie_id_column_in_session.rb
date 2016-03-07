class RenameCookieIdColumnInSession < ActiveRecord::Migration
  def change
      rename_column :sessions, :cookie_id_id, :cookie_id
  end
end
