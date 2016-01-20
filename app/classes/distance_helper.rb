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

  def self.pretty_minutes minutes, long_units
    if long_units
      h_unit_single = 'hour'
      h_unit_multiple = 'hours'
      min_unit_single = 'minute'
      min_unit_multiple = 'minutes'
      less_than = 'less than'
      one = 'one'
    else
      h_unit_single = 'h'
      h_unit_multiple = 'h'
      min_unit_single = 'min'
      min_unit_multiple = 'min'
      less_than = '<'
      one = '1'
    end

    if minutes > 60
      if long_units
        return (minutes / 60).to_s + ' ' + ( (minutes / 60) == 1 ? h_unit_single : h_unit_multiple ) + ' and ' + (minutes % 60).to_s + ' ' + ( (minutes % 60) == 1 ? min_unit_single : min_unit_multiple )
      else
        return (minutes / 60).to_s + ':' + (minutes % 60).to_s + ( (minutes % 60).to_s.length == 1 ? '0' : '' ) + ' h'
      end
    elsif minutes > 0
      return (minutes == 1 ? one : minutes.to_s) + ' ' + (minutes == 1 ? min_unit_single : min_unit_multiple)
    elsif minutes < 0
      return '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
    else
      return less_than + ' ' + one + ' ' + min_unit_single
    end
  end

  def self.pretty_distance meters, unit_in, unit_out, long_units
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

    return send(method, meters, long_units)

  end

  private

  def self.pretty_distance_m2km meters, long_units
    meters = meters.to_i
    m_unit = long_units ? 'meters' : 'm'
    km_unit = long_units ? 'kilometers' : 'km'

    if meters < 0
      return '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
    elsif 0 == meters
      return '0 ' + m_unit
    elsif meters > 999
      return (meters.to_f / 1000).round(1).to_s + ' ' + km_unit
    else
      return meters.to_s + ' ' + m_unit
    end
  end

  def self.pretty_distance_km2km kilometers, long_units
    kilometers = kilometers.round(1)
    m_unit = long_units ? 'meters' : 'm'
    km_unit = long_units ? 'kilometers' : 'km'

    if kilometers < 0
      return '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
    elsif 0 == kilometers
      return '0 ' + km_unit
    elsif kilometers < 1.00
      return (kilometers * 1000).round.to_s + ' ' + m_unit
    else
      return kilometers.to_s + ' ' + km_unit
    end
  end

end
