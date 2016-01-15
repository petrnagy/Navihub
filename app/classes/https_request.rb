class HttpsRequest

  require 'net/http'
  require 'net/https'
  require 'uri'

  public

  def initialize url
    @url = url
  end

  def get
    uri = URI.parse(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end

end
