class SearchEngine
  
  public
  
  class MethodNotOverridden < StandardError
  end
  
  def initialize params
    @params = params
  end
  
  def search
    raise MethodNotOverridden
  end
  
  protected
  
  private
  
end
