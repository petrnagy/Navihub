class SearchEngine
  
  require 'net/http'
  require 'net/https'
  require 'uri'
  
  public
  
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
  
  private
  
  def init_keys # @todo move to config !
    @google_api_key = 'AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI'
  end
  
end