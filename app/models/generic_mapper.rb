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
      :address    => nil,
      # - - -
      :detail     => {
        :url          => nil, 
        :website_url  => nil, 
        :phones       => [],
        :email        => nil,
        :address      => {
          :country        => nil,
          :country_short  => nil, 
          :town           => nil, 
          :zip            => nil, 
          :street         => nil, 
          :premise        => nil, 
        },
      },
    }
  end
  
  private
  
end