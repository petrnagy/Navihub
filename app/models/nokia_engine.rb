class NokiaEngine < SearchEngine
  
  @me
  
  def search
    @me = 'nokia'
    map parse get prepare
  end
  
  private
  
  def prepare
    term = @params[:term]
    url = 'https://places.cit.api.here.com/places/v1/discover/search'
    url += '?q=' + term
    url += '&at=' + @location.latitude.to_s + ',' + @location.longitude.to_s
    url += '&size=500'
    url += '&tf=plain'
    url += '&pretty=false'
    url += '&app_id=' + @nokia_app_id
    url += '&app_code=' + @nokia_app_code
    URI::escape(url)
  end
  
end