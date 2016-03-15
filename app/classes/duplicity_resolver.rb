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
        index = 0
        @data.each_with_index do |current, key|
            current[:is_unique] = true
            current[:uid] = index.to_i
            original = find_original resolved, current

            if original != nil
                resolved[original[:uid]] = resolve_by_merge original, current
            else
                resolved[current[:uid]] = current
            end
            index = index + 1
        end
        @resolved = resolved.select { |v| nil != v }
    end

    private

    def find_original processed, current
        processed.each_with_index do |old, key|
            detector = DuplicityDetector.new @term, old, current
            is_duplicate = detector.is_duplicate

            return old if is_duplicate
        end
        nil
    end

    def resolve_by_merge first, second
        result = second.merge first
        if first[:geometry][:lat] == nil || first[:geometry][:lng] == nil
            if second[:geometry][:lat] != nil && second[:geometry][:lng] != nil
                result = first.merge second
            end
        end

        result[:tags] = first[:tags] | second[:tags]
        result[:is_unique] = false
        # TODO: presunout adresu, pokud je prvni prazdna
        # TODO: presunout geolokaci, pokud je prvni prazdna
        result[:origins].push first[:origin]
        result[:origins].push second[:origin]
        result[:origins].uniq!

        result
    end

end
