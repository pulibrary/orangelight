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
    get 'browse/subjects/:id',
        model: Orangelight::Subject,
        as: 'browse_subject',
        to: 'browsables#show'
  end
  mount Requests::Engine, at: '/requests'

  Blacklight::Marc.add_routes(self)
  root to: 'catalog#index'

  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resource :catalog, only: [:index], path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  mount BlacklightAdvancedSearch::Engine => '/'

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'sessions' },
             skip: [:passwords, :registration]

  devise_scope :user do
    get '/users/signup' => 'devise/registrations#new', :as => :new_user_registration
    post '/users' => 'devise/registrations#create', :as => :user_registration
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

  ### For feedback Form
  get 'feedback', to: 'feedback#new'
  post 'feedback', to: 'feedback#create'

  get '/thumbnail/:id', to: 'thumbnail#show'

  # error pages
  match '/404' => 'errors#missing', via: [:get, :post, :patch, :delete]
  match '/422' => 'errors#missing', via: [:get, :post, :patch, :delete]
  match '/500' => 'errors#error', via: [:get, :post, :patch, :delete]
  # match '*catch_unknown_routes', to: 'application#catch_404s', via: [:get, :post]
  #
  get '/course_reserves', to: 'course_reserves#index'
end
