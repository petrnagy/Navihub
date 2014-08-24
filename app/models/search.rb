class Search
  
  public
  
  @@allowed_orders = %w{distance name relevance}
  @@allowed_engines = %w{google bing openstreet yelp foursquare}
  
  @params; @engines; @results;
  
  def initialize params
    @params = {
      :term => params['term'],
      :order => determine_order(params['order']),
      :offset => determine_offset(params['offset']),
    }
    @engines = determine_search_engines params['engines']
  end
  
  def search
    results = []
    fibers = {}
    @engines.each do |name|
      engine = "#{name.capitalize}Engine".constantize.new @params
      fibers[name] = {
        :fiber => Fiber.new do |lambda|
          lambda.call
        end,
        :lambda => lambda do |engine|
          engine.search
        end
      }
    end
    fibers.each do |payload|
      results < payload[:fiber].resume(payload[:lambda])
    end
    unless results.length == 0 then
      results = order results
      results = limit results
    end
    @results = results
  end
  
  def get_results
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
    engines.split(',').each do |engine|
      allowed < engine if @@allowed_engines.include? engine
    end if engines.is_a? String
    allowed.length > 0 ? allowed : @@allowed_engines
  end
  
  def order
    # @todo method
  end
  def limit
    # @todo method
  end
  
end
