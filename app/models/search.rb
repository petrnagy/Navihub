class Search
  
  public
  
  protected
  
  @@allowed_orders = %w{distance name}
  # bing openstreet - those are shits
  @@allowed_engines = %w{google nokia yelp foursquare}
  
  private
  
  @params; @location; @engines; @results; 
  @timeout; @total_cnt;
  
  public
  
  attr_reader :results, :params, :total_cnt
  
  def initialize params, location
    term = params[:term]
    term = term.strip! || term
    term = term.gsub(%r{\ +}, ' ')
    @params = {
      :term => term,
      :order => determine_order(params['order']),
      :offset => determine_offset(params['offset']),
      :radius => params.has_key?('radius') ? params['radius'] : 500, # meters
      :limit => 21,
      :step => 21,
      :append => params[:append]
    }
    if ! params['is_xhr'] && @params[:offset] > 0 # calculate limit instead of offset for non-ajax requests
      if @params[:offset] % @params[:limit] == 0
        @params[:limit] = @params[:limit] * ( (@params[:offset] / @params[:limit]) + 1 );
      end
      @params[:offset] = 0
    end
    @engines = determine_search_engines params['engines']
    @timeout = 3
    @location = location
  end
  
  def search
    ts_start = Time.now
    results = []
    threads = []
    @engines.each do |name|
      engine = "#{name.capitalize}Engine".constantize.new @params, @location
      threads << Thread.new do
        # require all the files which thread requires to make it "thread-safe"
        require 'net/http'
        require 'net/https'
        require 'uri'
        results << engine.search  
        Thread.exit if results.length == @engines.length || (Time.now - ts_start) > @timeout
      end
    end
    threads.each { |t| t.abort_on_exception = false; t.join }
    unless results.length == 0 then
      results = flatten results
      results = map results
      @total_cnt = results.length
      results = preprocess results
      results = order results
      results = limit results, @params[:limit], @params[:offset]
      results = postprocess results
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
    offset =~ /^[0-9]+$/ && offset.to_i >= 0 ? offset.to_i : 0
  end
  
  def determine_search_engines engines
    return @@allowed_engines # This functionality is turned off on FE - ATM
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
  
  def map results
    mapper = ResultsMapper.new results
    mapper.map_all
  end
  
  def preprocess results
    processed = []
    results.each do |current|
      if current[:geometry][:lat] != nil && current[:geometry][:lat] != nil
        current[:distance] = Location.calculate_distance(
          @location.latitude.to_f, 
          @location.longitude.to_f, 
          current[:geometry][:lat], 
          current[:geometry][:lng]
        ) unless current[:distance].to_i > 0
      end
      processed << current
    end
    processed
  end
  
  def order results
    sorter = ResultsSorter.new results
    sorter.sort(@params[:order][:by], @params[:order][:dir] == 'asc')
  end
  
  def limit results, limit, offset
    results.slice offset, limit
  end
  
  def postprocess results
    processed = []
    generic_engine = SearchEngine.new nil, nil
    key = generic_engine.google_api_key
    results.each do |current|
      if current[:geometry][:lat] != nil && current[:geometry][:lat] != nil
        # generate static map img
        current[:map] = GoogleMap.get_result_tn current[:geometry][:lat], current[:geometry][:lng], key
        # add location label
        current[:pretty_loc] = Location.pretty_loc current[:geometry][:lat], current[:geometry][:lng]
        if current[:distance] > 1000
          current[:distance] = DistanceHelper.m_to_km current[:distance], '.', 1
        else
          current[:distance] = current[:distance].to_i
        end
        current[:mtime] = Time.now.usec
      end
      # modify labels
      tags = []
      current[:tags].each do |tag|
        tags << tag.gsub('_', '-').gsub(' ', '-').downcase unless tag == nil
      end
      current[:tags] = tags
      
      processed << current
    end
    processed
  end
  
end