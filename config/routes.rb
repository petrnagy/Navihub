Rails.application.routes.draw do

    get 'feedback' => 'feedback#index'

    get 'about' => 'about#index'

    get 'settings/general'

    get 'settings/location' => 'settings#location'

    get 'settings/profile'

    root 'homepage#index'

    get 'search' => 'search#index'
    get 'find' => 'search#find'
    get 'search/:term(/:radius)(/:order)(/:offset)' => 'search#find'

    get 'detail/:name/:id/:origin' => 'detail#index'
    get 'detail/:name/:origin' => 'detail#index'

    get 'permalink/:permalink_id' => 'detail#permalink'
    post 'setpermalink' => 'permalinks#create'
    get 'favorites/add/:id/:origin' => 'favorite#create'
    get 'favorites' => 'search#favorites'

    post 'feedback' => 'feedback#process_contact_form'

end
