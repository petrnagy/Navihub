Rails.application.routes.draw do
  
  get 'settings/general'

  get 'settings/location'

  get 'settings/profile'

  root 'homepage#index'
  
  get 'search' => 'search#index'
  get 'find' => 'search#find'
  #get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find'
  #get 'search/:term(/:radius)(/:order)(/:offset)', :controller => 'search', :action => 'find', :term => /[^\/]+/
  
  get 'detail/:name/:id/:origin' => 'detail#index'
  
end
