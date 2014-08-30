class GenericMapper
  
  protected
  
  @data; 
  @@template = {
    :origin     => nil,
    :geometry   => { :lat => nil, :lng => nil },
    :id         => nil,
    :icon       => nil,
    :image      => nil,
    :name       => nil,
    :title      => nil,
    :tags       => [],
    :vicinity   => nil,
  }
  
  public
  
  class MethodNotOverridden < StandardError
  end
  
  def initialize data
    @data = data
  end
  
  def map
    raise MethodNotOverridden 
  end
  
  protected
  
  private
  
end