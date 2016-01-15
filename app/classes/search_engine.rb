class SearchEngine

  require 'net/http'
  require 'net/https'
  require 'uri'

  public

  attr_reader :google_api_key # do not touch

  class MethodNotOverridden < StandardError
  end

  def initialize params, location
    @params = params
    @location = location
    init_keys
  end

  def preflight
    raise MethodNotOverridden
  end

  def download
    raise MethodNotOverridden
  end

  def finalize
    raise MethodNotOverridden
  end

  protected

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
    if data == nil
      l = Logger.new(STDOUT)
      l.debug 'Engine ' + @me + ' returned nil'
    else
      if data['results'].length > 0
        data['results'].each do |venue|
          mapped = map_venue venue
          venues << mapped if mapped
        end
      end
    end
    venues
  end

  def map_venue venue
    return {
      :origin => @me,
      :data => venue
    }
  end

  def init_keys
    # TODO: presunout do pole
    @google_api_key = Rails.configuration.google_api_key
    @bing_api_key = Rails.configuration.bing_api_key
    @nokia_app_id = Rails.configuration.nokia_app_id
    @nokia_app_code = Rails.configuration.nokia_app_code
    @yelp_consumer_key = Rails.configuration.yelp_consumer_key
    @yelp_consumer_secret = Rails.configuration.yelp_consumer_secret
    @yelp_token = Rails.configuration.yelp_token
    @yelp_token_secret = Rails.configuration.yelp_token_secret
    @foursquare_client_id = Rails.configuration.foursquare_client_id
    @foursquare_client_secret = Rails.configuration.foursquare_client_secret
  end

end
