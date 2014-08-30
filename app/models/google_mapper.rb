class GoogleMapper < GenericMapper
  
  def map
    mapped = get_template

    mapped[:origin] = @data[:origin]
    mapped[:geometry][:lat] = @data[:data]['geometry']['location']['lat']
    mapped[:geometry][:lng] = @data[:data]['geometry']['location']['lng']
    mapped[:id] = @data[:data]['id']
    mapped[:icon] = @data[:data]['icon']
    mapped[:name] = @data[:data]['name']
    mapped[:tags] = @data[:data]['types']
    mapped[:vicinity] = @data[:data]['vicinity']
    
    [mapped]
  end
  
end