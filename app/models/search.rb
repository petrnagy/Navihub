class Search
  
  require 'json'
  require 'digest/md5'
  
  public
  
  protected
  
  @@allowed_orders = %w{distance name rand}
  # bing openstreet - those are shits
  @@allowed_engines = %w{google nokia yelp foursquare}
  @@max_distance = 20000; # 20km
  
  private
  
  @params; @location; @engines; @results; 
  @timeout; @total_cnt; @results_from_cache;
  
  public
  
  attr_reader :results, :params, :total_cnt, :results_from_cache
  
  def self.allowed_engines
    @@allowed_engines
  end
  
  def initialize params, location
    term = params[:term]
    term = term.strip! || term
    term = term.gsub(%r{\ +}, ' ')
    @params = {
      :term     => term,
      :order    => determine_order(params['order']),
      :offset   => determine_offset(params['offset']),
      :radius   => determine_radius(params['radius']),
      :limit    => 21,
      :step     => 21,
      :append   => params[:append]
    }
    # FIXME: pri nacteni "more 21 results" 
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
    key = Digest::MD5.hexdigest([@params, @engines, @location].to_json)
    cached = ApiCache.get_from_cache key
    if cached != nil
      results = cached
      @results_from_cache = true
    else
      results = search_async
      @results_from_cache = false
    end
    ApiCache.save_to_cache key, results if results && ! @results_from_cache
    process_results results
  rescue
    # ! ! ! ! ! ! ! ! ! ! ! ! ! HACK ! ! ! ! ! ! ! ! ! ! ! ! !
    # if non-threadsafe code raised error, we request the APIs again, without multithreading
    results = search_sync
    ApiCache.save_to_cache(key, results) if results
    process_results results
  end
  
  private
  
  def process_results results
    unless results.length == 0 then
      results = filter preprocess map flatten results
      @total_cnt = results.length
      results = postprocess limit(order(results), @params[:limit], @params[:offset])
    end
    @results = results
  end
  
  def search_async
    ts_start = Time.now
    results = []
    threads = []
    @engines.each do |name|
      engine = "#{name.capitalize}Engine".constantize.new @params, @location
      threads << Thread.new do
        results << engine.search  
        Thread.exit if results.length == @engines.length || (Time.now - ts_start) > @timeout
      end
    end
    threads.each { |t| t.abort_on_exception = false; t.join }
    results
  end
  
  def search_sync
    results = []
    @engines.each do |name|
      engine = "#{name.capitalize}Engine".constantize.new @params, @location
      results << engine.search        
    end
    results
  end
  
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
  
  def determine_radius radius
    if radius == nil || radius.to_i <= 0
      @@max_distance
    else
      radius.to_i  
    end
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
  
  def filter results
    processed = []
    results.each do |current|
      if nil != current[:distance] && current[:distance] <= @params[:radius]
        processed << current
      end
    end
    resolver = DuplicityResolver.new processed, @params[:term]
    resolver.resolve
    resolver.resolved
  end
  
  def preprocess results
    processed = []
    results.each do |current|
      current[:mtime] = Time.now.usec
      if current[:geometry][:lat] != nil && current[:geometry][:lat] != nil
        current[:distance] = Location.calculate_distance(
          @location.latitude.to_f, 
          @location.longitude.to_f, 
          current[:geometry][:lat], 
          current[:geometry][:lng]
          # TODO: zajistit, aby bylo vzdy v metrech
        ) unless current[:distance].to_i > 0
      end
      current[:duplicates] = Hash.new
      current[:origins].push current[:origin]
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
        current[:map] = GoogleMap.get_result_tn current[:geometry][:lat], current[:geometry][:lng], key
        current[:pretty_loc] = Location.pretty_loc current[:geometry][:lat], current[:geometry][:lng]
      elsif current[:address] != nil
        current[:map] = GoogleMap.get_result_tn_by_address current[:address], key
      end
      if current[:distance] != nil
        current[:distance_in_mins] = DistanceHelper.m_to_min current[:distance]
        current[:car_distance_in_mins] = DistanceHelper.car_m_to_min current[:distance]
        if current[:distance] > 1000
          current[:distance] = DistanceHelper.m_to_km current[:distance], '.', 1
          current[:distance_unit] = 'km'
        else
          current[:distance] = current[:distance].to_i
          current[:distance_unit] = 'm'
        end
      end
      # modify labels
      tags = []
      current[:tags].each do |tag|
        tags << Mixin.normalize_tag(tag) if tag.is_a? String
      end
      current[:tags] = tags
      current[:ascii_name] = Mixin.normalize_unicode current[:name]
      current[:json] = current.to_json
      
      processed << current
    end
    processed
  end
  
end