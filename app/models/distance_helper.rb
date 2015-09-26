class DistanceHelper

  # meters to kilometers
  def self.m_to_km meters, separator = '.', rounding = 2
    (meters / 1000).round(rounding).to_s.gsub('.', separator)
  end

  # kilometers to meters
  def self.km_to_m km
    (km * 1000).to_i
  end

  # meters to feets
  def self.m_to_ft m
    (m.to_f * 3.281).to_i
  end

  # kilometres to miles
  def self.km_to_mi km
    (km * 0.6214).round 2
  end

  # about 4km/h
  def self.m_to_min m
    (m / 1.1 / 60).to_i
  end

  # about 20km/h
  def self.car_m_to_min m
    (m / 5.556 / 60).to_i
  end

  # kilometers to minutes
  def self.km_to_min km
    self.m_to_min(km * 1000)
  end

  def self.pretty_minutes minutes
    if minutes > 60
      return (minutes / 60).to_s + ':' + (minutes % 60).to_s + ( (minutes % 60).to_s.length == 1 ? '0' : '' ) + ' h'
    elsif minutes > 0
      return minutes.to_s + ' min' + (minutes == 1 ? '' : 's')
    else
      return '< 1 min'
    end
  end

end
