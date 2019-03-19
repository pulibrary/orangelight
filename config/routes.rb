# frozen_string_literal: true

Rails.application.routes.draw do
  # mount Blacklight::Folders::Engine, at: "blacklight"
  # namespace :orangelight do
  #   resources :names
  # end

  scope module: 'orangelight' do
    get 'browse', to: 'browsables#browse'
    get 'browse/call_numbers', model: Orangelight::CallNumber, to: 'browsables#index'
    get 'browse/names', model: Orangelight::Name, to: 'browsables#index'
    get 'browse/name_titles', model: Orangelight::NameTitle, to: 'browsables#index'
    get 'browse/subjects', model: Orangelight::Subject, to: 'browsables#index'
  end
  mount Requests::Engine, at: '/requests'

  get 'catalog/:id/staff_view', to: 'catalog#librarian_view', as: 'staff_view_solr_document'

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
    member do
      get 'stackmap'
    end
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
      get 'csv'
      get 'print'
    end
  end

  mount BlacklightAdvancedSearch::Engine => '/'

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'sessions' },
             skip: %i[passwords registration]

  devise_scope :user do
    get '/users/signup' => 'devise/registrations#new', :as => :new_user_registration
    post '/users' => 'devise/registrations#create', :as => :user_registration
  end

  get '/numismatics', to: 'advanced#numismatics'

  get '/catalog/oclc/:id', to: 'catalog#oclc'
  get '/catalog/isbn/:id', to: 'catalog#isbn'
  get '/catalog/lccn/:id', to: 'catalog#lccn'
  get '/catalog/issn/:id', to: 'catalog#issn'
  get '/cgi-bin/Pwebrecon.cgi', to: redirect('/account'),
                                constraints: ->(r) { r.params[:PAGE] == 'pbLogon' }
  get '/cgi-bin/Pwebrecon.cgi', to: 'catalog#voyager'

  get '/notes' => 'high_voltage/pages#show', id: 'notes'
  get '/help' => 'high_voltage/pages#show', id: 'help'

  get '/account', to: 'account#index'
  post '/account/renew', to: 'account#renew'
  post '/account/cancel', to: 'account#cancel'

  get '/borrow-direct', to: 'account#borrow_direct_redirect'

  ### For feedback Form
  get 'feedback', to: 'feedback#new'
  post 'feedback', to: 'feedback#create'

  get '/thumbnail/:id', to: 'thumbnail#show'

  # error pages
  match '/404' => 'errors#missing', via: %i[get post patch delete]
  match '/422' => 'errors#missing', via: %i[get post patch delete]
  match '/500' => 'errors#error', via: %i[get post patch delete]
  # match '*catch_unknown_routes', to: 'application#catch_404s', via: [:get, :post]
  #
  get '/course_reserves', to: 'course_reserves#index'
end
