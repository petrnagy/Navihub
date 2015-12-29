class CreateIpinfoCaches < ActiveRecord::Migration
  def change
    create_table :ipinfo_caches do |t|
      t.timestamps
    end
  end
end
