class Ipinfo

  require 'net/http'
  require 'net/https'
  require 'uri'

  def dig ip
    url = 'http://ipinfo.io/' + ip + '/json'
    loc = map parse get(url)
  end

  private

  def map data

    ll = data['loc'].split(',')
    {
      'lat' => ll.first,
      'lng' => ll.second
    }
  end

  def get url
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    headers = { 'Content-Type' => "application/json" }
    path = uri.path.empty? ? "/" : uri.path
    code = http.head(path, headers).code.to_i
    if (code >= 200 && code < 300) then
      res = http.get(uri.path, headers)
      return res
    else
      return nil
    end
  end

  def parse response
    if response.instance_of?(Net::HTTPOK)
      JSON.parse response.body
    else
      nil
    end
  end

end
