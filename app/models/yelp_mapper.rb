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
          mapped[:tags] << cat[1]
        end    
      end
    end
    
    mapped[:distance] = @data[:data]['distance']
    mapped[:url] = @data[:data]['url']
    mapped[:phone] = @data[:data]['dislay_phone']
    
    [mapped]
  end
  
end