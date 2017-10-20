Rails.application.routes.draw do
    # home route
    root 'welcome#index'

    # page home routes
    get '/' => 'welcome#index'
    get '/about' => 'about#index'
    get '/blog' => 'blogs#index'
    get '/loadout' => 'loadout#index1'
    get '/reviews' => 'reviews#index'

    # blog routes
    get '/blog/:id' => 'blogs#show'

    # cart routes
    get '/create' => 'items#create'
    get '/add' => 'items#add'
    get '/update' => 'items#update'
    get '/delete' => 'items#destroy'

    # admin dashboard
    get '/admin' => 'admins#index'
    get '/login' => 'admins#login'

    # alexa commander routes
    get '/comparison_chart' => 'alexa#comparison_chart'
end
