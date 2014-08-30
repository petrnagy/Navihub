class Location < ActiveRecord::Base
  belongs_to :user
  
  def self.possible lat, lng
    (lat.to_f <= 90 && lat.to_f >= 0 && lng.to_f <= 180 && lng.to_f >= -180)
  end
  
end
