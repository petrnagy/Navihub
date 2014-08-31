class ResultsSorter
  
  @data
  
  def initialize input_array
    @data = input_array
  end
  
  def sort by, asc = true
    case by
    when 'name'
      lambda = ->(a, b) { a[:name] <=> b[:name] }
    when 'distance'    
      lambda = ->(a, b) { a[:distance] <=> b[:distance] }
    end
    data = @data.clone.sort(& lambda)
    asc ? data : data.reverse
  end
  
end