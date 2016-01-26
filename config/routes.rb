Rails.application.routes.draw do
  # mount Blacklight::Folders::Engine, at: "blacklight"
  # namespace :orangelight do
  #   resources :names
  # end

  scope module: 'orangelight' do
    get 'browse', to: 'browsables#browse'
    get 'browse/call_numbers', model: Orangelight::CallNumber, to: 'browsables#index'
    get 'browse/names', model: Orangelight::Name, to: 'browsables#index'
    get 'browse/names/:id', model: Orangelight::Name, as: 'browse_name', to: 'browsables#show'
    get 'browse/subjects', model: Orangelight::Subject, to: 'browsables#index'
    get 'browse/subjects/:id', model: Orangelight::Subject, as: 'browse_subject', to: 'browsables#show'
  end

  Blacklight::Marc.add_routes(self)
  root :to => "catalog#index"
  blacklight_for :catalog

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :skip => [:passwords, :registration]

  devise_scope :user do
    get "/users/signup" => "devise/registrations#new", :as => :new_user_registration
    post "/users" => "devise/registrations#create", :as => :user_registration
  end

  get '/catalog/oclc/:id', to: 'catalog#oclc'
  get '/catalog/isbn/:id', to: 'catalog#isbn'
  get '/catalog/lccn/:id', to: 'catalog#lccn'
  get '/catalog/issn/:id', to: 'catalog#issn'

  get '/notes' => 'high_voltage/pages#show', id: 'notes'
  get '/help' => 'high_voltage/pages#show', id: 'help'

  get '/account', to: 'account#index'
  post '/account/renew', to: 'account#renew'
  post '/account/cancel', to: 'account#cancel'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  #
  get "/thumbnail/:id", to: "thumbnail#show"

  # error pages
  match "/404" => "errors#missing", via: [ :get, :post, :patch, :delete ]
  match "/422" => "errors#missing", via: [ :get, :post, :patch, :delete ]
  match "/500" => "errors#error", via: [ :get, :post, :patch, :delete ]
  # match '*catch_unknown_routes', to: 'application#catch_404s', via: [:get, :post]
end
