Rails.application.routes.draw do

    # homepage
    root 'homepage#index' # [xss-safe] [csrf-part-safe]
    # account management
    get 'account' => 'account#index'
    get 'account/index' => 'account#index'
    get 'account/login'
    post 'account/login' => 'account#process_login'
    get 'account/logout'
    post 'account/logout' => 'account#process_logout'
    get 'account/create'
    post 'account/create' => 'account#process_create'
    get 'account/created/:username/:created_hash' => 'account#created'
    get 'account/manage'
    get 'account/update'
    get 'account/close'
    get 'account/verify/:username/:hash' => 'account#verify'

    get 'auth/:provider/callback' => 'account#omniauth'

    # feedback page
    get 'feedback' => 'feedback#index' # [xss-safe] [csrf-part-safe]
    post 'feedback' => 'feedback#process_contact_form' # [xss-safe] [csrf-part-safe]
    # settings
    get 'settings/general' # [not-implemented]
    post 'settings/location' => 'settings#location_set' # [xss-safe] [csrf-part-safe]
    get 'settings/location' => 'settings#location' # [xss-safe] [csrf-part-safe]
    get 'settings/profile' # [not-implemented]
    # detail
    get 'detail/:name/:id/:origin/@/:lat,:lng' => 'detail#index', # [xss-safe] [csrf-part-safe]
        :constraints => { :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/, :id => /.+/, :name => /.+/ }
    get 'detail/:name/:origin/@/:lat,:lng' => 'detail#index', # [xss-safe] [csrf-part-safe]
        :constraints => { :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/, :id => /.+/, :name => /.+/ }
    # permalinks
    get 'permalink/:permalink_id' => 'permalinks#show' # [xss-safe] [csrf-part-safe]
    put 'setpermalink' => 'permalinks#create' # [xss-safe] [csrf-part-safe]
    # search
    get 'search' => 'search#index' # [xss-safe] [csrf-part-safe]
    get 'search/:order/:radius/:offset/@/:lat,:lng' => 'search#find', # [xss-safe] [csrf-part-safe]
        :constraints => { :order => /\w+\-\w+/, :radius => /\d+/, :offset => /\d+/,
            :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/ }
    get 'search/:term/:order/:radius/:offset/@/:lat,:lng' => 'search#find', # [xss-safe] [csrf-part-safe]
        :constraints => { :order => /\w+\-\w+/, :radius => /\d+/, :offset => /\d+/,
            :lat => /\-?\d+(\.\d+)?/, :lng => /\-?\d+(\.\d+)?/ }
    # lazy search-related endpoints
    get 'lazy/geocode' => 'search#geocode' # [xss-safe] [csrf-part-safe]
    get 'lazy/reversegeocode' => 'search#reverse_geocode' # [xss-safe] [csrf-part-safe]
    get 'lazy/static-map-img' => 'search#get_static_map_image' # [xss-safe] [csrf-part-safe]
    get 'lazy/distance-matrix' => 'search#distance_matrix' # [xss-safe] [csrf-part-safe]
    #favorites
    put 'favorites' => 'favorites#create' # [xss-safe] [csrf-part-safe]
    delete 'favorites' => 'favorites#delete' # [xss-safe] [csrf-part-safe]
    get 'favorites' => 'favorites#index' # [xss-safe] [csrf-part-safe]
    # sharing
    post 'sharer/email' => 'sharer#email' # [xss-safe] [csrf-part-safe]
    # logger
    post 'logger/js' => 'logger#js' # [xss-safe] [csrf-part-safe]

    match '*unmatched_route', :to => 'application#raise_not_found!', :via => :all

end
