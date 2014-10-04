class DistanceHelper
  
  def self.m_to_km meters, separator = '.', rounding = 2
    (meters / 1000).round(rounding).to_s.gsub('.', separator)
  end
  
  def self.km_to_m km
    (km * 1000).to_i
  end
  
  def self.m_to_ft m
    (m.to_f * 3.281).to_i
  end
  
  def self.km_to_mi km
    (km * 0.6214).round 2
  end
  
  def self.m_to_min m
    (m / 1.1 / 60).to_i
  end
  
  def self.car_m_to_min m
    (m / 5.556 / 60).to_i
  end
  
  def self.km_to_min km
    self.m_to_min(km * 1000)
  end
  
end