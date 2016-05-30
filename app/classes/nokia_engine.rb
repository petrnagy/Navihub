class NokiaEngine < SearchEngine

  def preflight
    @me = 'nokia'
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
    url = 'https://places.cit.api.here.com/places/v1/discover/search'
    url += '?q=' + term
    #url += '&at=' + @location.latitude.to_s + ',' + @location.longitude.to_s
    url += '&size=100'
    url += '&in=' + @location.latitude.to_s + ',' + @location.longitude.to_s + ';r=' + @params[:radius].to_s + ';cgen=gps'
    url += '&tf=plain'
    url += '&pretty=false'
    url += '&app_id=' + @nokia_app_id
    url += '&app_code=' + @nokia_app_code
    URI::escape(url)
  end

end
