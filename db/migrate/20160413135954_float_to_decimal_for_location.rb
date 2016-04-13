class FloatToDecimalForLocation < ActiveRecord::Migration
  def change
      change_column :locations, :latitude, :decimal, :precision => 15, :scale => 7
      change_column :locations, :longitude, :decimal, :precision => 15, :scale => 7
  end
end
