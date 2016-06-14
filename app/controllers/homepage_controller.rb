class HomepageController < ApplicationController
  def index
      return render 'errors/400'
  end
end
