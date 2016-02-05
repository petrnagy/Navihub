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
    get 'detail/:name/:id/:origin/@/:lat,:lng' => 'detail#index', # [xss-safe]
        :constraints => { :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/, :id => /.+/, :name => /.+/ }
    get 'detail/:name/:origin/@/:lat,:lng' => 'detail#index', # [xss-safe]
        :constraints => { :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/, :id => /.+/, :name => /.+/ }
    # permalinks
    get 'permalink/:permalink_id' => 'permalinks#show' # [xss-safe]
    put 'setpermalink' => 'permalinks#create' # [xss-safe]
    # search
    get 'search' => 'search#index' # [xss-safe]
    get 'search/:order/:radius/:offset/@/:lat,:lng' => 'search#find', # [xss-safe]
        :constraints => { :order => /\w+\-\w+/, :radius => /\d+/, :offset => /\d+/,
            :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/ }
    get 'search/:term/:order/:radius/:offset/@/:lat,:lng' => 'search#find', # [xss-safe]
        :constraints => { :order => /\w+\-\w+/, :radius => /\d+/, :offset => /\d+/,
            :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/ }
    # lazy search-related endpoints
    get 'lazy/geocode' => 'search#geocode' # [xss-safe]
    get 'lazy/reversegeocode' => 'search#reverse_geocode' # [xss-safe]
    get 'lazy/static-map-img' => 'search#get_static_map_image' # [xss-safe]
    get 'lazy/distance-matrix' => 'search#distance_matrix' # [xss-safe]
    #favorites
    put 'favorites' => 'favorites#create' # [not-safe]
    delete 'favorites' => 'favorites#delete' # [xss-safe]
    get 'favorites' => 'favorites#index' # [xss-safe]
    # sharing
    post 'sharer/email' => 'sharer#email' # [xss-safe]
    # homepage
    root 'homepage#index' # [xss-safe]

end
