Rails.application.routes.draw do
  mount Blacklight::Folders::Engine, at: "blacklight"
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
  
  get 'guided', to: 'advanced#guided'
  
  Blacklight::Marc.add_routes(self)
  root :to => "catalog#index"
  blacklight_for :catalog

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
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
end
