Rails.application.routes.draw do
  
  root 'homepage#index'
  
  get 'search' => 'search#index'
  get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find'
  
end
