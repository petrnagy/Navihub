class GenericVenueLoader < SearchEngine
  
  protected
  
  @id; 
  
  public
  
  def initialize id
    @id = id
    init_keys
  end
  
  def load
    raise MethodNotOverridden 
  end
  
end