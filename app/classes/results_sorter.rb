class ResultsSorter
  
  @data
  
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
    end
    unless lambda == nil then
      data = data.sort(& lambda)
    end
    asc ? data : data.reverse
  end
  
end