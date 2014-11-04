class NokiaMapper < GenericMapper
  
  include ActionView::Helpers::SanitizeHelper
  
  def map
    results = []
    for i in 0..@data[:data].length do
      # elements may come in random order
      if @data[:data][i].is_a?(Array)
        @data[:data][i].each do |item|
          unless item['position'] == nil
            mapped = get_template
    
            mapped[:origin] = @data[:origin]
            mapped[:geometry][:lat] = item['position'][0]
            mapped[:geometry][:lng] = item['position'][1]
            #mapped[:id] = item['id']
            # TODO: needs refactoring
            mapped[:id] = (item['href'].split('?').first).split('/').last
            mapped[:icon] = item['icon']
            mapped[:name] = item['title']
            mapped[:tags] = [item['category']['title']]
            mapped[:vicinity] = item['vicinity']
      
            mapped[:address] = item['vicinity']
            
            results << mapped
          end
        end
      end
      
    end
    results
  end
  
  def map_detail location
    mapped = get_template
    
    mapped[:origin] = 'Nokia Here'
    mapped[:geometry][:lat] = @data['location']['position'][0]
    mapped[:geometry][:lng] = @data['location']['position'][1]
    mapped[:id] = @data['placeId']
    mapped[:icon] = @data['icon']
    mapped[:name] = @data['name']
    mapped[:tags] = []
    if @data['categories'].is_a? Array
      @data['categories'].each do |cat|
        mapped[:tags] << cat['id'].downcase
      end
    end
    if @data['tags'].is_a? Array
      @data['tags'].each do |tag|
        mapped[:tags] << tag['id'].downcase
        mapped[:tags] << tag['group'].downcase
      end
    end
    mapped[:tags].uniq!
    mapped[:vicinity] = nil
    mapped[:address] = strip_tags(@data['location']['address']['text'].gsub('<br/>', ' '))
    
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
    mapped[:detail][:url] = @data['view']
    mapped[:detail][:website_url] = nil
    mapped[:detail][:address][:premise] = @data['location']['address']['house']
    mapped[:detail][:address][:street] = @data['location']['address']['street']
    mapped[:detail][:address][:town] = @data['location']['address']['city']
    mapped[:detail][:address][:country] = @data['location']['address']['country']
    mapped[:detail][:address][:country_short] = @data['location']['address']['countryCode']
    mapped[:detail][:address][:zip] = @data['location']['address']['postalCode']
    if mapped[:detail][:address][:street] && mapped[:detail][:address][:premise] &&mapped[:detail][:address][:town] && mapped[:detail][:address][:country]
      mapped[:address] = mapped[:detail][:address][:street] + ' ' + mapped[:detail][:address][:premise] + ', ' + mapped[:detail][:address][:town] + ', ' + mapped[:detail][:address][:country]
    end
     
    if @data['contacts']
      if @data['contacts']['phone'].is_a? Array
        @data['contacts']['phone'].each do |phone|
          mapped[:detail][:phones] << phone['value']
        end
      end
    end
    
    mapped
  end
  
end