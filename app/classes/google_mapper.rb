class GoogleMapper < GenericMapper

  def map
    mapped = get_template

    mapped[:origin] = @data[:origin]
    mapped[:geometry][:lat] = @data[:data]['geometry']['location']['lat']
    mapped[:geometry][:lng] = @data[:data]['geometry']['location']['lng']
    mapped[:id] = @data[:data]['place_id']
    mapped[:icon] = @data[:data]['icon']
    mapped[:name] = @data[:data]['name']
    mapped[:tags] = @data[:data]['types']
    mapped[:vicinity] = @data[:data]['vicinity']

    mapped[:address] = @data[:data]['vicinity']

    [mapped]
  end

  def map_detail location
    mapped = get_template

    mapped[:origin] = 'google'
    mapped[:geometry][:lat] = @data['result']['geometry']['location']['lat']
    mapped[:geometry][:lng] = @data['result']['geometry']['location']['lng']
    mapped[:id] = @data['result']['place_id']
    mapped[:icon] = @data['result']['icon']
    mapped[:name] = @data['result']['name']
    mapped[:tags] = @data['result']['types']
    mapped[:vicinity] = @data['result']['vicinity']
    mapped[:address] = @data['result']['formatted_address']
    # - - -
    mapped[:ascii_name] = Mixin.normalize_unicode mapped[:name]
    if mapped[:geometry][:lat] != nil && mapped[:geometry][:lng] != nil

      mapped[:pretty_loc] = Location.pretty_loc mapped[:geometry][:lat], mapped[:geometry][:lng]

      mapped[:distance] = Location.calculate_distance(
        location.latitude.to_f,
        location.longitude.to_f,
        mapped[:geometry][:lat],
        mapped[:geometry][:lng]
      ).ceil unless mapped[:distance].to_i > 0
      mapped[:distance_in_mins] = DistanceHelper.m_to_min mapped[:distance]
      mapped[:car_distance_in_mins] = DistanceHelper.car_m_to_min mapped[:distance]
      if mapped[:distance] > 1000
        mapped[:distance] = DistanceHelper.m_to_km mapped[:distance], '.', 1
        mapped[:distance_unit] = 'km'
      else
        mapped[:distance] = mapped[:distance].to_i
        mapped[:distance_unit] = 'm'
      end

    end
    mapped[:detail][:url] = @data['result']['url']
    mapped[:detail][:website_url] = @data['result']['website_url']

    mapped[:detail][:phone] = @data['result']['formatted_phone_number']
    if mapped[:detail][:phone].to_s == ''
        mapped[:detail][:phone] = @data['result']['international_phone_number']
    end

    mapped[:detail][:rating] = @data['result']['rating']
    unless nil == mapped[:detail][:rating]
        if mapped[:detail][:rating].to_f == 0.00
            mapped[:detail][:rating] = nil
        else
            mapped[:detail][:rating] = Mixin.round5(mapped[:detail][:rating])
        end
    end

    if @data['result']['address_components'].is_a? Array

      @data['result']['address_components'].each do |item|
        if item['types'].is_a?(Array) && (item['long_name'] || item['short_name'])
          if item['types'].include? 'premise'
            mapped[:detail][:address][:premise] = item['long_name'] || item['short_name']
          elsif item['types'].include? 'route'
            mapped[:detail][:address][:street] = item['long_name'] || item['short_name']
          elsif item['types'].include? 'locality'
            mapped[:detail][:address][:town] = item['long_name'] || item['short_name']
          elsif item['types'].include? 'country'
            mapped[:detail][:address][:country] = item['long_name']
            mapped[:detail][:address][:country_short] = item['short_name']
          elsif item['types'].include? 'postal_code'
            mapped[:detail][:address][:zip] = item['long_name'] || item['short_name']
          end
        end
      end

    end

    mapped
  end

end
