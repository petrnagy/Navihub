class DistanceHelper

  class NotImplementedError < StandardError
  end

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
      return minutes.to_s + ' min' #+ (minutes == 1 ? '' : 's')
    elsif minutes < 0
      return '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
    else
      return '< 1 min'
    end
  end

  def self.pretty_distance meters, unit_in, unit_out
    unit_in = unit_in.to_s
    # TODO: not implemented yet
    unit_out = 'km'
    meters = meters.to_f

    unless ['m', 'km'].include? unit_in
      raise NotImplementedError, 'debug: ' + unit_in.to_s
    end
    if unit_out != 'km'
      raise NotImplementedError, 'debug: ' + unit_out.to_s
    end

    method = 'pretty_distance_' + unit_in + '2' + unit_out

    return send(method, meters)

  end

  private

  def self.pretty_distance_m2km meters
    meters = meters.to_i

    if meters < 0
      return '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
    elsif 0 == meters
      return '0 m'
    elsif meters > 999
      return (meters.to_f / 1000).round(1).to_s + ' km'
    else
      return meters.to_s + ' m'
    end
  end

  def self.pretty_distance_km2km kilometers
    kilometers = kilometers.round(1)

    if kilometers < 0
      return '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
    elsif 0 == kilometers
      return '0 km'
    elsif kilometers < 1.00
      return (kilometers * 1000).round.to_s + ' m'
    else
      return kilometers.to_s + ' km'
    end
  end

end
