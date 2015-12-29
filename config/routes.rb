Rails.application.routes.draw do

    get 'feedback' => 'feedback#index'
    get 'about' => 'about#index'

    get 'settings/general'
    get 'settings/location' => 'settings#location'
    get 'settings/profile'

    get 'detail/:name/:id/:origin' => 'detail#index'
    get 'detail/:name/:origin' => 'detail#index'

    get 'permalink/:permalink_id' => 'permalinks#show'
    put 'setpermalink' => 'permalinks#create'

    get 'search' => 'search#index'
    get 'find' => 'search#find'
    get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find'
    get 'lazy/geocode' => 'search#geocode'
    get 'lazy/reversegeocode' => 'search#reverse_geocode'
    #get 'lazy/ipinfo' => 'search#ipinfo'

    put 'favorites' => 'favorites#create'
    delete 'favorites' => 'favorites#delete'
    get 'favorites' => 'favorites#index'

    post 'feedback' => 'feedback#process_contact_form'

    post 'sharer/email' => 'sharer#email'

    root 'homepage#index'

end
