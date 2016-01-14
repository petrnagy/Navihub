class Search

    require 'json'
    require 'digest/md5'

    protected

    @@allowed_orders = %w{distance name rand}
    @@allowed_engines = %w{google nokia yelp foursquare}
    @@max_distance = 20000; # 20km

    private

    @params; @location; @engines; @results;
    @timeout; @total_cnt; @results_from_cache;
    @user;

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
        key = Digest::MD5.hexdigest([@params, @engines, @location, @user.id].to_json)
        cached = ApiCache.get_from_cache key

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
            processed << current
        end

        processed
    end

    # result-specific methods

    def load_result_geometry result
        if result[:geometry][:lat] != nil && result[:geometry][:lng] != nil
            return result[:geometry]
        elsif result[:address].is_a?(String) && result[:address].length > 0
            loc = GeocodeCache.load result[:address]
            if loc != nil
                return { :lat => loc['lat'], :lng => loc['lng'], :cached => true }
            end
        end
        return { :lat  => nil, :lng => nil }
    end

    def load_result_distance result
        if result[:distance].to_i > 0
            return result[:distance]
        elsif result[:geometry][:lat] != nil && result[:geometry][:lng] != nil
            return Location.calculate_distance(
            @location.latitude.to_f,
            @location.longitude.to_f,
            result[:geometry][:lat],
            result[:geometry][:lng]
            )
        else
            return nil
        end
    end

    def result_pretty_loc result
        if result[:geometry][:lat] != nil && result[:geometry][:lng] != nil
            return Location.pretty_loc result[:geometry][:lat], result[:geometry][:lng]
        elsif result[:geometry][:cached] == true
            return '<i class="fa fa-frown-o"></i>'.html_safe
        else
            return nil
        end
    end

    def result_map result, key
        if result[:geometry][:lat] != nil && result[:geometry][:lat] != nil
            return GoogleMap.get_result_tn result[:geometry][:lat], result[:geometry][:lng], key
        elsif result[:address] != nil
            return GoogleMap.get_result_tn_by_address result[:address], key
        else
            return nil
        end
    end

    def result_favorite result, favorites
        # FIXME: this is SLOOOOW !!!
        favorites.each do |fav|
            if fav.venue_id.to_s == result[:id].to_s
                if fav.venue_origin.to_s == result[:origin].to_s
                    return true
                end
            end
        end
        return false
    end

    def result_normalize_tags result
        tags = []
        result[:tags].each do |tag|
            tags << Mixin.normalize_tag(tag) if tag.is_a? String
        end
        return tags
    end

    def result_confirm_address result
        if nil == result[:address] || result[:address].strip.length <= 1 || result[:address].strip =~ /^\d+$/
            spinner = '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
            if result[:geometry][:lat] != nil && result[:geometry][:lat] != nil
                cached = ReverseGeocodeCache.load result[:geometry][:lat], result[:geometry][:lng]
                if cached == nil
                    return spinner
                else
                    if cached.addr == nil
                        return '<i class="fa fa-frown-o"></i>'.html_safe
                    else
                        return cached.addr
                    end
                end
            else
                return spinner
            end
        else
            return result[:address]
        end
    end

end
