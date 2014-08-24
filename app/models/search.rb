class Search
  
  public
  
  @@allowed_orders = %w{distance name relevance}
  @@allowed_engines = %w{google bing openstreet yelp foursquare}
  
  @term; @order; @offset; @engines
  
  attr_reader @@allowed_orders
  attr_reader @@allowed_engines
  
  def initialize params
    @term = params['term']
    @order = determine_order params['order']
    @offset = determine_offset params['offset']
    @engines = determine_search_engines params['engines']
  end
  
  def start
    
  end
  
  def get
    @order
  end
  
  protected
  
  private
  
  def determine_order order
    if order.is_a? String
      order = order.split('-')
      if order.length == 2
        if @@allowed_orders.include? order[0]
          return {
            :by  => order[0],
            :dir => order[1] == 'desc' ? 'desc' : 'asc'
          }
        end
      end
    end
    { :by => 'distance', :dir => 'asc' }
  end
  
  def determine_offset offset
    offset.is_a?(Integer) && offset >= 0 ? offset : 0
  end
  
  def determine_search_engines engines
    allowed = []
    if engines.is_a?(Array)
      engines.each do |engine|
        if @@allowed_engines.include? engine
          allowed < engine
        end
      end
    end
    allowed.length > 0 ? allowed : @@allowed_engines
  end
  
end
