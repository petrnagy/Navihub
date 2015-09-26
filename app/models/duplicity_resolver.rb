class DuplicityResolver

  private
  @data; @resolved

  @@duplicity_score_threshold = 0.9
  @@distance_threshold = 250

  public

  attr_reader :resolved

  def initialize data, term
    @data = data
    @term = term
  end

  def resolve
    resolved = []
    @data.each_with_index do |val, key|
      val[:is_unique] = true
      distance = 0.00

      candidate = get_duplicity_candidate resolved, val
      unless nil == candidate then
        if nil != resolved[candidate][:geometry][:lat] &&
            nil != resolved[candidate][:geometry][:lng] &&
            nil != val[:geometry][:lat] &&
            nil != val[:geometry][:lng]
          distance = Location.calculate_distance(
            resolved[candidate][:geometry][:lat], resolved[candidate][:geometry][:lng],
            val[:geometry][:lat], val[:geometry][:lng])
        else # be aware that this can generate false-positive output
          distance = (resolved[candidate][:distance] - val[:distance]).abs
        end
        val[:is_unique] = distance > @@distance_threshold
      end
      if ! val[:is_unique]
        #logger = Logger.new(STDOUT)
        #logger.debug 'Duplicate detected: ' + resolved[candidate][:name] + ' vs ' + val[:name] + ', distance: ' + distance.to_s

        resolved[candidate] = resolve_by_merge resolved[candidate], val
      else
        resolved[key] = val
      end
    end
    @resolved = resolved.select { |v| nil != v }
  end

  private

  def get_duplicity_candidate processed, current
    processed.each_with_index do |old, candidate|
      unless nil == old then
        detector = DuplicityDetector.new @term, old[:name], current[:name]
        score = detector.get_score
        if score >= @@duplicity_score_threshold
          return candidate
        end
      end
    end
    return nil
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
    result[:origins].push first[:origin]
    result[:origins].push second[:origin]
    result[:origins].uniq!

    result
  end

end
