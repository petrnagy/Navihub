class CreateApiCaches < ActiveRecord::Migration
  def change
    create_table :api_caches do |t|

      t.timestamps
    end
  end
end
