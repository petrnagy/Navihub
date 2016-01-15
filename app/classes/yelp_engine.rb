class YelpEngine < SearchEngine

  def preflight
    @me = 'yelp'
    @request = prepare
  end

  def download
    @request[:token].get(@request[:uri])
  end

  def finalize response
    map parse response
  end

  protected

  def prepare
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
    #url += '&offset=' + @params[:offset].to_s
    url += '&offset=0'
    url += '&radius=' + @params[:radius].to_s
    url += '&term=' + @params[:term]
    { :token => access_token, :uri => URI::escape(url) }
  end

  def map data
    venues = []
    unless data == nil
      if data['businesses'].length > 0
        data['businesses'].each do |venue|
          mapped = map_venue venue
          venues << mapped if mapped
        end
      end
    end
    venues
  end

end
