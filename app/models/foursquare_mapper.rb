class FoursquareMapper < GenericMapper
  
  def map
    mapped = get_template
    
    mapped[:origin] = @data[:origin]
    mapped[:geometry][:lat] = @data[:data]['venue']['location']['lat']
    mapped[:geometry][:lng] = @data[:data]['venue']['location']['lng']
    mapped[:id] = @data[:data]['venue']['id']
    mapped[:name] = @data[:data]['venue']['name']
    mapped[:vicinity] = @data[:data]['venue']['location']['address']
    if @data[:data]['venue']['categories'].is_a? Array
      @data[:data]['venue']['categories'].each do |cat|
        mapped[:tags] << cat['name']
      end
    end
    [mapped]
  end
  
end