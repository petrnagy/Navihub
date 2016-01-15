class GoogleEngine < SearchEngine

  def preflight
    @me = 'google'
    @request = HttpsRequest.new prepare
  end

  def download
    @request.get
  end

  def finalize response
    map parse response
  end

  protected

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
