class ResultsSorter

    require 'text'

    def initialize input_array
        @data = input_array
    end

    def sort by, asc = true
        data = @data.clone
        lambda = nil
        case by
        when 'name'
            lambda = ->(a, b) { a[:name] <=> b[:name] }
        when 'distance'
            lambda = ->(a, b) { a[:distance] <=> b[:distance] }
        when 'rand'
            data.shuffle!
        when 'match'
            lambda = ->(a, b) {
                comparator = Text::WhiteSimilarity.new
                scoreA = comparator.similarity a[:term], a[:name]
                scoreB = comparator.similarity b[:term], b[:name]
                return -1 if scoreA > scoreB
                return  1 if scoreB > scoreA
                return  0
            }
        end
        unless lambda == nil then
            data = data.sort(& lambda)
        end
        asc ? data : data.reverse
    end

end
