class FoursquareMapper < GenericMapper

  def map
    mapped = get_template
    #logger = Logger.new(STDOUT)
    #logger.debug 'RESULT: ' + @data.to_s;
    mapped[:origin] = @data[:origin]
    mapped[:geometry][:lat] = @data[:data]['venue']['location']['lat']
    mapped[:geometry][:lng] = @data[:data]['venue']['location']['lng']
    mapped[:id] = @data[:data]['venue']['id']
    mapped[:name] = @data[:data]['venue']['name']
    mapped[:vicinity] = @data[:data]['venue']['location']['address']
    if @data[:data]['venue']['categories'].is_a? Array
      @data[:data]['venue']['categories'].each do |cat|
        #mapped[:tags] << cat['name']
        mapped[:tags] << Mixin.normalize_tag(cat['name'])
      end
    end

    mapped[:address] = @data[:data]['venue']['location']['address'].to_s + ', ' + @data[:data]['venue']['location']['city'].to_s

    [mapped]
  end

  def map_detail location
    mapped = get_template

    mapped[:origin] = 'FourSquare Venues'
    mapped[:geometry][:lat] = @data['response']['venue']['location']['lat']
    mapped[:geometry][:lng] = @data['response']['venue']['location']['lng']
    mapped[:id] = @data['response']['venue']['id']
    mapped[:icon] = nil
    mapped[:name] = @data['response']['venue']['name']
    mapped[:tags] = []
    @data['response']['venue']['categories'].each do |cat|
      mapped[:tags] << Mixin.normalize_tag(cat['name'])
    end
    mapped[:vicinity] = nil
    mapped[:address] = @data['response']['venue']['location']['formattedAddress'].join ', '
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
    mapped[:detail][:url] = URI.decode @data['response']['venue']['canonicalUrl']
    mapped[:detail][:website_url] = nil

    mapped[:detail][:address][:premise] = nil
    mapped[:detail][:address][:street] = nil
    mapped[:detail][:address][:town] = @data['response']['venue']['location']['city']
    mapped[:detail][:address][:country] = @data['response']['venue']['location']['country']
    mapped[:detail][:address][:country_short] = @data['response']['venue']['location']['cc']
    mapped[:detail][:address][:zip] = @data['response']['venue']['location']['postalCode']

    mapped
  end

end
