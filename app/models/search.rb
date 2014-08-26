class Search
  
  public
  
  protected
  
  @@allowed_orders = %w{distance name relevance}
  #@@allowed_engines = %w{google bing openstreet yelp foursquare}
  @@allowed_engines = %w{google}
  
  private
  
  @params; @location; @engines; @results; 
  @timeout;
  
  public
  
  attr_reader :results
  
  def initialize params, location
    @params = {
      :term => params['term'],
      :order => determine_order(params['order']),
      :offset => determine_offset(params['offset']),
      :radius => params.has_key?('radius') ? params['radius'] : 500, # meters
    }
    @engines = determine_search_engines params['engines']
    @timeout = 5
    @location = location
  end
  
  def search
    ts_start = Time.now
    results = []
    threads = []
    @engines.each do |name|
      # do not put new instance initialization in the thread because of 'Circular dependency' bug !
      engine = "#{name.capitalize}Engine".constantize.new @params, @location
      threads << Thread.new do
        results << engine.search
        Thread.exit if results.length == @engines.length || (Time.now - ts_start) > @timeout
      end
    end
    threads.each { |t| t.abort_on_exception = false; t.join }
    unless results.length == 0 then
      results = flatten results
      results = order results
      results = limit results
    end
    @results = results
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
      allowed << engine if @@allowed_engines.include? engine
    end if engines.is_a? String
    allowed.length > 0 ? allowed : @@allowed_engines
  end
  
  def flatten results
    flattened = []
    results.each do |result|
      flattened.concat result
    end
    flattened
  end
  
  def order results
    results
    # @todo method
  end
  def limit results
    results
    # @todo method
  end
  
end