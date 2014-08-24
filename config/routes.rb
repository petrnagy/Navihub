Rails.application.routes.draw do
  
  root 'homepage#index'
  
  get 'search' => 'search#index'
  get 'search/:term(/:order)(/:offset)(/:engines)' => 'search#find'
  
end
