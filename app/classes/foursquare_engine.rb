class FoursquareEngine < SearchEngine

  def preflight
    @me = 'foursquare'
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

    url = 'https://api.foursquare.com/v2/venues/explore'
    url += '?query=' + term
    url += '&ll=' + @location.latitude.to_s + ',' + @location.longitude.to_s
    url += '&radius=' + @params[:radius].to_s
    #url += '&limit=' + @params[:limit].to_s
    url += '&limit=50'
    url += '&m=foursquare'
    url += '&v=20140806'
    url += '&client_id=' + @foursquare_client_id
    url += '&client_secret=' + @foursquare_client_secret
    URI::escape(url)
  end

  def map data
    venues = []
    unless data == nil
      data['response']['groups'].each do |group|
        group['items'].each do |venue|
          mapped = map_venue venue
          if mapped
            mapped['group'] = group['name']
            venues << mapped
          end
        end
      end
    end
    venues
  end

end
