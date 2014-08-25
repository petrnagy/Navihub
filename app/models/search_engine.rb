class SearchEngine
  
  public
  
  class MethodNotOverridden < StandardError
  end
  
  def initialize params, location
    @params = params
    @location = location
  end
  
  def search
    raise MethodNotOverridden
  end
  
  protected
  
  private
  
end