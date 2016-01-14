Rails.application.routes.draw do

    # feedback page
    get 'feedback' => 'feedback#index' # [safe]
    post 'feedback' => 'feedback#process_contact_form' # [refactored, not-checked]
    # about page
    get 'about' => 'about#index' # [safe]
    # settings
    get 'settings/general' # []
    get 'settings/location' => 'settings#location' # []
    get 'settings/profile' # []
    # detail
    get 'detail/:name/:id/:origin' => 'detail#index' # []
    get 'detail/:name/:origin' => 'detail#index' # []
    # permalinks
    get 'permalink/:permalink_id' => 'permalinks#show' # []
    put 'setpermalink' => 'permalinks#create' # []
    # search
    get 'search' => 'search#index' # []
    get 'find' => 'search#find' # []
    get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find' # []
    # lazy search-related endpoints
    get 'lazy/geocode' => 'search#geocode' # []
    get 'lazy/reversegeocode' => 'search#reverse_geocode' # []
    #get 'lazy/ipinfo' => 'search#ipinfo' # working but unused (cannot determine user IP from JS)
    #favorites
    put 'favorites' => 'favorites#create' # []
    delete 'favorites' => 'favorites#delete' # []
    get 'favorites' => 'favorites#index' # []
    # sharing
    post 'sharer/email' => 'sharer#email' # []
    # homepage
    root 'homepage#index' # []

end
