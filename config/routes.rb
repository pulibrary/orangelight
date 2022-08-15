# frozen_string_literal: true

Rails.application.routes.draw do
  mount Flipflop::Engine => "/features"
  scope module: 'orangelight' do
    get 'browse', to: 'browsables#browse'
    get 'browse/call_numbers', model: Orangelight::CallNumber, to: 'browsables#index'
    get 'browse/names', model: Orangelight::Name, to: 'browsables#index'
    get 'browse/name_titles', model: Orangelight::NameTitle, to: 'browsables#index'
    get 'browse/subjects', model: Orangelight::Subject, to: 'browsables#index'
  end
  scope module: 'requests' do
    get "/requests", to: 'request#index'
    post '/requests/borrow_direct', to: 'request#borrow_direct'
    post '/requests/submit', to: 'request#submit'
    # no longer in use
    # get '/pageable', to: 'request#pageable'
    get '/requests/:system_id', to: 'request#generate', constraints: { system_id: /(\d+|dsp\w+|SCSB-\d+|coin-\d+)/i }
    post '/requests/:system_id', to: 'request#generate', constraints: { system_id: /(\d+|dsp\w+|SCSB-\d+|coin-\d+)/i }
  end
  get 'catalog/:id/staff_view', to: 'catalog#librarian_view', as: 'staff_view_solr_document'
  post '/catalog/:id/linked_records/:field', to: 'catalog#linked_records'

  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
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
    concerns [:exportable, :marc_viewable]
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
  get '/dataset' => 'high_voltage/pages#show', id: 'dataset'

  get '/account', to: 'account#index'
  get '/account/digitization_requests', to: 'account#digitization_requests', as: "digitization_requests"
  post '/account/cancel_ill_requests', to: 'account#cancel_ill_requests'
  get '/borrow-direct', to: 'account#borrow_direct_redirect'
  get '/account/user-id', to: 'account#user_id'
  get '/account/admin', to: 'account#admin'
  get '/redirect-to-alma', to: 'account#redirect_to_alma'

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
end
