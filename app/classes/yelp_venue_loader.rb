class YelpVenueLoader < GenericVenueLoader

  def load location
    parse get
  end

  private

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
    url = '/v2/business'
    url += '/' + @id.to_s
    access_token.get(URI::escape url)
  end

end
