class DetailController < ApplicationController
  
  def index
    if params.has_key?('origin') && params.has_key?('id')
      @data = load params['origin'], params['id']
      if @data
        return render 'detail'
      end
    end
    @data = { :origin => params['origin'] || 'unknown', :id => params['id'] || 'unknown' }
    render 'empty'
  end
  
  private
  
  def load origin, id
    if Search.allowed_engines.include? origin
      
    end
  end
  
end
