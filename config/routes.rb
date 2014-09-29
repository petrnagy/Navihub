Rails.application.routes.draw do
  
  get 'settings/general'

  get 'settings/location'

  get 'settings/profile'

  root 'homepage#index'
  
  get 'search' => 'search#index'
  get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find'
  
end
