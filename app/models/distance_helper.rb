class DistanceHelper
  
  def self.m_to_km meters, separator = '.', rounding = 2
    (meters / 1000).round(rounding).to_s.gsub('.', separator)
  end
  
  def self.km_to_m km
    (km * 1000).to_i
  end
  
  def self.m_to_mi m
    
  end
  
end