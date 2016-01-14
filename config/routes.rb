Rails.application.routes.draw do

    # feedback page
    get 'feedback' => 'feedback#index' # [xss-safe]
    post 'feedback' => 'feedback#process_contact_form' # [xss-safe]
    # about page
    get 'about' => 'about#index' # [xss-safe]
    # settings
    get 'settings/general' # [not-implemented]
    get 'settings/location' => 'settings#location' # [xss-safe]
    get 'settings/profile' # [not-implemented]
    # detail
    get 'detail/:name/:id/:origin' => 'detail#index' # [xss-safe]
    get 'detail/:name/:origin' => 'detail#index' # [xss-safe]
    # permalinks
    get 'permalink/:permalink_id' => 'permalinks#show' # [xss-safe]
    put 'setpermalink' => 'permalinks#create' # [xss-safe]
    # search
    get 'search' => 'search#index' # [xss-safe]
    get 'find' => 'search#find' # [xss-safe]
    get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find' # [xss-safe]
    # lazy search-related endpoints
    get 'lazy/geocode' => 'search#geocode' # [xss-safe]
    get 'lazy/reversegeocode' => 'search#reverse_geocode' # [xss-safe]
    #favorites
    put 'favorites' => 'favorites#create' # [not-safe]
    delete 'favorites' => 'favorites#delete' # [xss-safe]
    get 'favorites' => 'favorites#index' # [xss-safe]
    # sharing
    post 'sharer/email' => 'sharer#email' # [xss-safe]
    # homepage
    root 'homepage#index' # [xss-safe]

end
