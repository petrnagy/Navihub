class DuplicityResolver

    private
    @data = nil
    @resolved = nil

    public

    attr_reader :resolved

    def initialize data, term
        @data = data
        @term = term
    end

    def resolve
        resolved = []
        @data.each do |current|
            next if current == nil
            index = resolved.length
            current[:is_unique] = true
            current[:uid] = index
            original = find_original resolved, current

            if original != nil
                resolved[original[:uid]] = resolve_by_merge original, current
            else
                resolved[current[:uid]] = current
            end
        end
        @resolved = resolved.select { |v| nil != v }
    end

    private

    def find_original processed, current
        processed.each do |old|
            detector = DuplicityDetector.new @term, old, current
            is_duplicate = detector.is_duplicate

            return old if is_duplicate
        end
        nil
    end

    def resolve_by_merge first, second
        result = second.merge first
        result[:tags] = first[:tags] | second[:tags]
        result[:is_unique] = false
        result[:origins] = result[:origins].push(first[:origin]).push(second[:origin]).uniq
        result
    end

end
