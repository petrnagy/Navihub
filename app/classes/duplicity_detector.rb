class DuplicityDetector

    require 'text' # http://rubygems.org/gems/text

    private

    @@duplicity_score_threshold = 1.0
    @@distance_threshold = 100

    @term = nil
    @old = nil
    @current = nil
    @old_sentence = nil
    @current_sentence = nil
    @old_raw = nil
    @current_raw = nil
    @old_address = nil
    @current_address = nil
    @distance = nil

    public

    def initialize term, old, current
        @old = old
        @current = current
        atomize term, @old[:name], @current[:name]
        locate @old[:geometry], @current[:geometry]
        address @old[:address], @current[:address]
    end

    # returns boolean
    def is_duplicate
        process
    end

    private

    def atomize term, old_sentence, current_sentence
        @term = term.strip.downcase
        @old_raw = old_sentence
        @current_raw = current_sentence
        @old_sentence = prepare old_sentence
        @current_sentence = prepare current_sentence
    end

    def locate old_geometry, current_geometry
        unless old_geometry[:lat] == nil || old_geometry[:lng] == nil
            unless current_geometry[:lat] == nil || current_geometry[:lng] == nil
                @distance = Location.calculate_distance(
                old_geometry[:lat],
                old_geometry[:lng],
                current_geometry[:lat],
                current_geometry[:lng]
                )
            end
        end
    end

    def address old_address, current_address
        @old_address = old_address
        @current_address = current_address
    end

    def prepare sentence
        prepared = sentence.clone
        prepared.strip!
        prepared.downcase!
        #prepared.gsub!(@term, '')
        prepared.gsub!(/\ +/, ' ')
        prepared.gsub!(/([^\d\w\ \-]|_)/u, ' ')
        prepared.split(' ')
    end

    def process
        return 1.00 if are_same # sentences are exactly the same
        return 1.00 if are_both_empty # both sentences are empty, thus the same
        return 0.00 if is_just_one_empty # one array is empty and the other one is not -> not similiar at all

        comparator = Text::WhiteSimilarity.new
        similarity_raw = comparator.similarity @old_raw, @current_raw
        similarity_prepared = comparator.similarity @old_sentence.join(' '), @current_sentence.join(' ')
        similarity = ( similarity_raw + similarity_prepared ) / 2

        score = similarity

        similarity_addr = comparator.similarity @old_address, @current_address
        score += similarity_addr

        shorter = get_shorter_sentence
        longer = get_longer_sentence
        if is_subarray shorter, longer
            score += 0.5 # longer array contains all the elements from the shorter array
        end

        unless @distance == nil
            if @distance <= @@distance_threshold
                score += 0.33
            end
        end

        l = Logger.new(STDOUT)
        l.debug '- - - DUPLICITY DETECTOR REPORT - - -'
        if score > @@duplicity_score_threshold
            l.debug 'Duplicate detected !'
        else
            l.debug 'Clean !'
        end
        l.debug 'OLD: ' + @old_raw + ', NEW: ' + @current_raw
        l.debug 'similarity_raw: ' + similarity_raw.to_s
        l.debug 'similarity_prepared: ' + similarity_prepared.to_s
        l.debug 'similarity: ' + similarity.to_s
        l.debug 'similarity_addr: ' + similarity_addr.to_s
        l.debug 'is_subarray shorter, longer: ' + (is_subarray(shorter, longer).to_s)
        l.debug 'distance: ' + @distance.to_s
        l.debug '@term: ' + @term.to_s
        l.debug '@old_sentence: ' + @old_sentence.to_s
        l.debug '@current_sentence: ' + @current_sentence.to_s
        l.debug '@old_raw: ' + @old_raw.to_s
        l.debug '@current_raw: ' + @current_raw.to_s
        l.debug '@old_address: ' + @old_address.to_s
        l.debug '@current_address: ' + @current_address.to_s
        l.debug '@distance: ' + @distance.to_s
        l.debug 'FINAL score: ' + score.to_s


        score > @@duplicity_score_threshold
    end

    def are_same
        @old_sentence.join('') == @current_sentence.join('')
    end

    def are_both_empty
        ! @old_sentence.length && ! @current_sentence.length
    end

    def is_just_one_empty
        if ! @old_sentence.length == 0 && @current_sentence.length > 0
            true
        elsif @old_sentence.length > 0 && ! @current_sentence.length == 0
            true
        else
            false
        end
    end

    def get_shorter_sentence
        @old_sentence.length < @current_sentence.length ? @old_sentence : @current_sentence
    end

    def get_longer_sentence
        @old_sentence.length > @current_sentence.length ? @old_sentence : @current_sentence
    end

    def is_subarray shorter, longer
        hits = 0
        shorter.each do |word|
            hits += 1 if longer.include? word
        end
        shorter.length == hits
    end

    def get_distance
        distance = 0.00

        unless nil == candidate then
            if nil != resolved[candidate][:geometry][:lat] &&
                nil != resolved[candidate][:geometry][:lng] &&
                nil != current[:geometry][:lat] &&
                nil != current[:geometry][:lng]
                distance = Location.calculate_distance(
                resolved[candidate][:geometry][:lat], resolved[candidate][:geometry][:lng],
                current[:geometry][:lat], current[:geometry][:lng])
            else # be aware that this can generate false-positive output
                distance = (resolved[candidate][:distance] - current[:distance]).abs
            end
            current[:is_unique] = distance > @@distance_threshold

            logger = Logger.new(STDOUT)
            logger.debug 'NOW Comparing: ' + resolved[candidate][:name] + ' vs ' + current[:name] + ', distance: ' + distance.to_s
        end

    end

end
