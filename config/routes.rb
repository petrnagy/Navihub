Rails.application.routes.draw do

    get 'feedback' => 'feedback#index'
    get 'about' => 'about#index'

    get 'settings/general'
    get 'settings/location' => 'settings#location'
    get 'settings/profile'

    get 'detail/:name/:id/:origin' => 'detail#index'
    get 'detail/:name/:origin' => 'detail#index'

    get 'permalink/:permalink_id' => 'detail#permalink'
    put 'setpermalink' => 'permalinks#create'

    get 'search' => 'search#index'
    get 'find' => 'search#find'
    get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find'

    put 'favorites' => 'favorites#create'
    delete 'favorites' => 'favorites#delete'
    get 'favorites' => 'search#favorites'

    post 'feedback' => 'feedback#process_contact_form'

    get 'sharer/email' => 'sharer#share_venue_via_email'

    root 'homepage#index'

end
