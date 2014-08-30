class GenericMapper
  
  protected
  
  @data; 
  
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
  
  def get_template
    {
      :origin     => nil,
      :geometry   => { :lat => nil, :lng => nil },
      :distance   => nil,
      :id         => nil,
      :icon       => nil,
      :image      => nil,
      :map        => nil,
      :name       => nil,
      :title      => nil,
      :tags       => [],
      :vicinity   => nil,
      :url        => nil,
      :phone      => nil,
    }
  end
  
  private
  
end