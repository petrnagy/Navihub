module ApplicationHelper
  
  def javascript(*files)
    content_for(:footer_js) { javascript_include_tag(*files) }
  end
  
  def pretty_loc location
    o = '';
    no_txt = true
    # iterate thru required fields
    %w{city city2 street1 street2}.each do |interest|
      if location[interest] != nil && location[interest].length > 0
        no_txt = false
        break
      end
    end
    
    if no_txt
      o += location['latitude'].to_s + ', ' + location['longitude'].to_s
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
  
end
