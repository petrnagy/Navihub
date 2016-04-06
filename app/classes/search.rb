class Search

    require 'json'
    require 'digest/md5'

    include SearchMixin

    protected

    @@allowed_orders = %w{distance name rand}
    @@allowed_engines = %w{google nokia yelp foursquare}
    @@max_distance = 20000; # 20km

    private

    public

    attr_reader :results, :params, :total_cnt, :results_from_cache

    def self.allowed_engines
        @@allowed_engines
    end

    def initialize parameters, location, user
        term = parameters['term']
        term = term.strip! || term
        term = term.gsub(%r{\ +}, ' ')
        @params = {
            :term     => term,
            :order    => determine_order(parameters['order']),
            :offset   => determine_offset(parameters['offset']),
            :radius   => determine_radius(parameters['radius']),
            :limit    => parameters['limit'],
            :step     => 21,
            :append   => parameters['append']
        }
        if ! parameters['is_xhr'] && @params[:offset] > 0 # calculate limit instead of offset for non-ajax requests
            if @params[:offset] % @params[:limit] == 0
                @params[:limit] = @params[:limit] * ( (@params[:offset] / @params[:limit]) + 1 );
            end
            @params[:offset] = 0
        end
        @engines = determine_search_engines parameters['engines']
        @timeout = 3
        @location = location
        @user = user
    end

    def search

        key = Digest::MD5.hexdigest([
            @params['term'], @params['radius'], @engines,
            @location.latitude.to_s, @location.longitude.to_s,
            (@user.favorites ? @user.id : nil)
        ].to_json)
        cached = ApiCache.get_from_cache key
        l = Logger.new(STDOUT)
        l.debug key
        if 0 === @params[:term].length
            return []
        elsif cached != nil
            results = cached
            @results_from_cache = true
        else
            results = search_async
            @results_from_cache = false
        end
        ApiCache.save_to_cache key, results if results && ! @results_from_cache
        process_results results
    end

    private

    def process_results results
        unless results.length == 0 then
            results = filter preprocess map flatten results
            @total_cnt = results.length
            results = postprocess limit(order(results), @params[:limit], @params[:offset]) unless 0 == @total_cnt
        end
        @results = results
    end

    def search_async
        engines = {}
        responses = {}
        results = []
        threads = []
        @engines.each do |name|
            engines[name] = "#{name.capitalize}Engine".constantize.new @params, @location
            engines[name].preflight
            threads << Thread.new do
                begin
                    responses[name] = engines[name].download
                rescue => ex
                    l = Logger.new(STDERR)
                    l.error 'Rescued: engine ' + name + ' probably timeouted, debug: ' + ex.to_s
                    responses[name] = nil
                end
            end
        end
        threads.each { |t| t.abort_on_exception = false; t.join }
        engines.each do |name, engine|
            results << engine.finalize(responses[name])
        end
        results
    end

    # def search_sync
    #     results = []
    #     @engines.each do |name|
    #         engine = "#{name.capitalize}Engine".constantize.new @params, @location
    #         results << engine.search
    #     end
    #     results
    # end

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
        # allowed = []
        # engines.split(',').each do |engine|
        #     allowed << engine if @@allowed_engines.include? engine
        # end if engines.is_a? String
        # allowed.length > 0 ? allowed : @@allowed_engines
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
            current[:geometry] = load_result_geometry current
            current[:distance] = load_result_distance current
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
        favorites = Favorite.find_by_user_id @user.id

        results.each do |current|
            current[:favorite] = result_favorite current, favorites
            current[:pretty_loc] = result_pretty_loc current
            current[:map] = result_map current, key
            current[:distance] = current[:distance].to_i unless current[:distance] == nil
            current[:distance_unit] = 'm' unless current[:distance] == nil
            current[:address] = result_confirm_address current
            current[:tags] = result_normalize_tags current
            current[:ascii_name] = Mixin.normalize_unicode current[:name]
            current[:json] = current.to_json
            current[:json_hash] = Digest::MD5.hexdigest current[:json]
            processed << current
        end

        processed
    end

end
