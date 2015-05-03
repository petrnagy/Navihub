# encoding: UTF-8

module ApplicationHelper

  def javascript(*files)
    content_for(:footer_js) { javascript_include_tag(*files) }
  end

  def pretty_loc location
    return '...' if nil == location

    o = ''
    no_txt = true
    # iterate thru required fields
    %w{city city2 street1 street2}.each do |interest|
      if location[interest] != nil && location[interest].length > 0
        no_txt = false
        break
      end
    end

    if no_txt
      #o += location['latitude'].round(2).to_s + ', ' + location['longitude'].round(2).to_s
      o += coords_to_dms location['latitude'], location['longitude']
    else
      %w{street2 street1 city2 city country}.each do |interest|
        if location[interest] != nil && location[interest].length > 0
          o += ', ' unless 0 == o.length
          o += location[interest]
        end
      end
      if location['country_short'] != nil && location['country_short'].length > 0
        o += ' (' + location['country_short'] + ')'
      end
    end

    o
  end

  def coords_to_dms lat, lng
    lat_direction = lat > 0.00 ? 'N' : 'S'
    lng_direction = lng > 0.00 ? 'E' : 'W'
    lat_degrees = lat.abs.floor
    lng_degrees = lng.abs.floor
    lat_decimal = (lat.abs - lat.abs.floor) * 3600
    lng_decimal = (lng.abs - lng.abs.floor) * 3600
    lat_minutes = (lat_decimal / 60).floor
    lng_minutes = (lng_decimal / 60).floor
    lat_seconds = (lat_decimal - (lat_minutes * 60)).round(0)
    lng_seconds = (lng_decimal - (lng_minutes * 60)).round(0)

    o = ''
    o += lat_degrees.to_s.rjust(2, '0') + '°' + lat_minutes.to_s.rjust(2, '0') + "'" + lat_seconds.to_s.rjust(2, '0') + '"' + lat_direction
    o += ' '
    o += lng_degrees.to_s.rjust(2, '0') + '°' + lng_minutes.to_s.rjust(2, '0') + "'" + lng_seconds.to_s.rjust(2, '0') + '"' + lng_direction
    o
  end

end
