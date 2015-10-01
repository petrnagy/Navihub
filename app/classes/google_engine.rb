class GoogleEngine < SearchEngine
  
  @me
  
  def search
    @me = 'google'
    map parse get prepare
  end
  
  private
  
  def prepare
    term = @params[:term]
    url = 'https://maps.googleapis.com/maps/api/place/search/json'
    url += '?name=' + term
    url += '&location=' + @location.latitude.to_s + ',' + @location.longitude.to_s
    url += '&radius=' + @params[:radius].to_s
    url += '&sensor=false'
    url += '&key=' + @google_api_key
    URI::escape(url)
  end
  
end