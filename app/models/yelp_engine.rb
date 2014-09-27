class YelpEngine < SearchEngine
  
  @me
  
  def search
    @me = 'yelp'
    map parse get
  end
  
  protected
  
  def get
    consumer = OAuth::Consumer.new(
      @yelp_consumer_key,
      @yelp_consumer_secret,
      {
        :site => 'http://api.yelp.com',
        :signature_method => 'HMAC-SHA1',
        :scheme => :query_string
      }
    )
    access_token = OAuth::AccessToken.new consumer, @yelp_token, @yelp_token_secret
    url = '/v2/search'
    url += '?ll=' + @location.latitude.to_s + ',' + @location.longitude.to_s
    url += '&limit=20' # current yelp limit is 20
    url += '&offset=' + @params[:offset].to_s
    url += '&radius=' + @params[:radius].to_s
    url += '&term=' + @params[:term]
    access_token.get(URI::escape url)
  end
  
  def map data
    venues = []
    if data['businesses'].length > 0
      data['businesses'].each do |venue|
        mapped = map_venue venue
        venues << mapped if mapped
      end
    end
    venues
  rescue
    []
  end
  
end