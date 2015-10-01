class ResultsMapper
  
  @results
  
  def initialize results
    @results = results
  end
  
  def map_all
    results = []
    @results.each do |result|
      mapper = "#{result[:origin].capitalize}Mapper".constantize.new result
      results.concat mapper.map
    end
    results
  end
  
  private
  
  
  
end