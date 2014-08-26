class GoogleEngine < SearchEngine
  
  def search
    map parse get prepare
  end
  
  private
  
  def prepare
    term = @params[:term]
    term = term.strip! || term
    term = term.gsub(%r{\ +}, ' ')
    url = 'https://maps.googleapis.com/maps/api/place/search/json'
    url += '?name=' + term
    url += '&location=' + @location.latitude.to_s + ',' + @location.longitude.to_s
    url += '&radius=' + @params[:radius].to_s
    url += '&sensor=false'
    url += '&key=' + @google_api_key
    URI::escape(url)
  end
  
  def get url
    https = HttpsRequest.new url
    https.get
  end
  
  def parse response
    if response.instance_of?(Net::HTTPOK)
      JSON.parse response.body
    else
      nil
    end
  end
  
  def map data
    venues = []
    if data['results'].length > 0
      data['results'].each do |venue|
        mapped = map_venue venue
        venues << mapped if mapped
      end
    end
    venues
  rescue
    []
  end
  
  def map_venue venue
    return {
      :origin => 'google',
      :data => venue
    }
  end
  
end