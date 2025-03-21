# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  scope module: 'orangelight' do
    get 'browse', to: 'browsables#browse'
    get 'browse/call_numbers', model: Orangelight::CallNumber, to: 'browsables#index'
    get 'browse/names', model: Orangelight::Name, to: 'browsables#index'
    get 'browse/name_titles', model: Orangelight::NameTitle, to: 'browsables#index'
    get 'browse/subjects', model: Orangelight::Subject, to: 'browsables#index'
  end
  scope module: 'requests' do
    get "/requests", to: 'form#index'
    post '/requests/submit', to: 'form#submit'
    # no longer in use
    # get '/pageable', to: 'form#pageable'
    get '/requests/:system_id', to: 'form#generate', constraints: { system_id: /(\d+|dsp\w+|SCSB-\d+|coin-\d+)/i }
    post '/requests/:system_id', to: 'form#generate', constraints: { system_id: /(\d+|dsp\w+|SCSB-\d+|coin-\d+)/i }
  end
  get 'catalog/:id/staff_view', to: 'catalog#librarian_view', as: 'staff_view_solr_document'
  post '/catalog/:id/linked_records/:field', to: 'catalog#linked_records'

  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  root to: 'catalog#index'

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

  mount Flipflop::Engine => '/features'

  mount HealthMonitor::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resource :catalog, only: [:index], path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
      get 'csv'
      get 'print'
    end
  end

  get '/advanced', to: 'catalog#advanced_search'

  get '/numismatics', to: 'catalog#numismatics'
  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'sessions' },
             skip: %i[passwords registration]

  devise_scope :user do
    get '/users/signup' => 'devise/registrations#new', :as => :new_user_registration
    post '/users' => 'devise/registrations#create', :as => :user_registration
    get "sign_out", to: "sessions#destroy"
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/catalog/oclc/:id', to: 'catalog#oclc'
  get '/catalog/isbn/:id', to: 'catalog#isbn'
  get '/catalog/lccn/:id', to: 'catalog#lccn'
  get '/catalog/issn/:id', to: 'catalog#issn'
  get '/cgi-bin/Pwebrecon.cgi', to: redirect('/account'),
                                constraints: ->(r) { r.params[:PAGE] == 'pbLogon' }
  get '/cgi-bin/Pwebrecon.cgi', to: 'catalog#alma'

  get '/notes' => 'high_voltage/pages#show', id: 'notes'
  get '/help' => 'high_voltage/pages#show', id: 'help'
  get '/dataset' => 'high_voltage/pages#show', id: 'dataset'

  get '/account', to: 'account#index'
  get '/account/digitization_requests', to: 'account#digitization_requests', as: "digitization_requests"
  post '/account/cancel_ill_requests', to: 'account#cancel_ill_requests'

  get '/borrow-direct', to: redirect('https://borrowdirect.reshare.indexdata.com/')

  get '/account/user-id', to: 'account#user_id'
  get '/redirect-to-alma', to: redirect('https://princeton.alma.exlibrisgroup.com/discovery/account?vid=01PRI_INST:Services&lang=EN&section=overview')

  ### For feedback Form
  get 'feedback', to: 'feedback#new'
  post 'feedback', to: 'feedback#create'

  # For "Ask a Question" form
  get "/ask_a_question", to: "feedback#ask_a_question"
  post "/contact/question", to: "contact#question"

  # For "Suggest A Correction form"
  get '/suggest_correction', to: 'feedback#suggest_correction'
  post '/contact/suggestion', to: 'contact#suggestion'

  # For "Report Harmful Language" form
  get "/report_harmful_language", to: "feedback#report_harmful_language"
  post "/contact/report_harmful_language", to: "contact#report_harmful_language"

  # For "Reporting Biased Search Results" form
  # TODO: change get route to '/report_biased_results'
  get '/feedback/biased_results', to: 'feedback#report_biased_results', as: 'feedback_biased_results'
  post '/contact/report_biased_results', to: 'contact#report_biased_results'

  get '/thumbnail/:id', to: 'thumbnail#show'

  # error pages
  match '/404' => 'errors#missing', via: %i[get post patch delete]
  match '/422' => 'errors#missing', via: %i[get post patch delete]
  match '/500' => 'errors#error', via: %i[get post patch delete]
  # match '*catch_unknown_routes', to: 'application#catch_404s', via: [:get, :post]
  #
end
