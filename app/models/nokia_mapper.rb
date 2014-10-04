class NokiaMapper < GenericMapper
  
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
            mapped[:id] = item['id']
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
  
end