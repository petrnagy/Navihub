class YelpMapper < GenericMapper

  def map
    mapped = get_template

    mapped[:origin] = @data[:origin]
    mapped[:id] = @data[:data]['id']
    mapped[:image] = @data[:data]['snippet_image_url']
    mapped[:name] = @data[:data]['name']
    mapped[:vicinity] = @data[:data]['location']['address']
    if @data[:data]['categories'].is_a? Array
      @data[:data]['categories'].each do |cat|
        unless cat[1] == nil
          mapped[:tags] << Mixin.normalize_tag(cat[1])
        end
      end
    end

    mapped[:distance] = @data[:data]['distance']
    mapped[:url] = @data[:data]['url']
    mapped[:phone] = @data[:data]['dislay_phone']

    mapped[:address] = @data[:data]['location']['address'][0].to_s + ', ' + @data[:data]['location']['city'].to_s;

    [mapped]
  end

  def map_detail location
    mapped = get_template

    mapped[:origin] = 'yelp'
    unless nil === @data['location'] || nil === @data['location']['coordinate']
      mapped[:geometry][:lat] = @data['location']['coordinate']['latitude'].to_f
      mapped[:geometry][:lng] = @data['location']['coordinate']['longitude'].to_f
    end
    mapped[:id] = @data['id']
    mapped[:icon] = nil
    mapped[:name] = @data['name']
    mapped[:tags] = []
    @data['categories'].each do |cat|
      mapped[:tags] << cat[1] unless cat[1] == nil
    end
    mapped[:vicinity] = nil
    mapped[:address] = @data['location']['display_address'].join ', '
    # - - -
    mapped[:ascii_name] = Mixin.normalize_unicode mapped[:name]
    # todo tel
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
    mapped[:detail][:url] = @data['url']
    mapped[:detail][:website_url] = nil

    mapped[:detail][:address][:premise] = nil
    mapped[:detail][:address][:street] = nil
    mapped[:detail][:address][:town] = @data['location']['city']
    mapped[:detail][:address][:country] = nil
    mapped[:detail][:address][:country_short] = @data['location']['country_code']
    mapped[:detail][:address][:zip] = @data['location']['postal_code']

    mapped
  end

end
