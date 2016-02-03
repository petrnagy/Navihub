class CreateDistanceMatrixCaches < ActiveRecord::Migration
  def change
    create_table :distance_matrix_caches do |t|
        t.string :source
        t.string :destination
        t.text :result
        t.timestamps
    end
    add_index :distance_matrix_caches, [:source, :destination], unique: true
  end
end
