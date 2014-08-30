class SearchEngine
  
  require 'net/http'
  require 'net/https'
  require 'uri'
  
  public
  
  attr_reader :google_api_key
  
  class MethodNotOverridden < StandardError
  end
  
  def initialize params, location
    @params = params
    @location = location
    init_keys
  end
  
  def search
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
      :origin => @me,
      :data => venue
    }
  end
  
  private
  
  def init_keys
    ## @todo move to config !
    @google_api_key = 'AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI'
    @bing_api_key = 'Au5anmaAZUPQzhdTJXEIsXoH8Zt0_BzN__yPAalAdd2x34xx8rwqFbLnCTYkcxI2'
    @nokia_app_id = 'CROI830RgnHxshc4IgUZ'
    @nokia_app_code = 'qg4VOSG75rX5rwsaVpEw3A'
    @yelp_consumer_key = 'RVKY3dj6gBpDD5Z0N32NXA'
    @yelp_consumer_secret = 'CUO5poUH-o6xjrjn_V_KbXMsRSE'
    @yelp_token = 'XRGAQulkW2g_LGK6-aAFvzRDvq_0vS6w'
    @yelp_token_secret = 'Fbh84XguagKdLx3dhuB0b-iTU_o'
    @foursquare_client_id = 'N4LIPVZBNTUVTC42Y051NIWKGQAYDNY5N5QKLZH5GYDOGXWB'
    @foursquare_client_secret = 'NHNMRKLYQYVOIA1AVVCMWWFN2GPBLVREDDODSP2ZHI0YC0RC'
  end
  
end