# frozen_string_literal: true

set :rvm_ruby_string, :local

set :stage, :production
set :rails_env, 'production'

set :branch, ENV['BRANCH'] || 'main'

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'catalog1.princeton.edu', user: 'deploy', roles: %i[web app db worker]
server 'catalog2.princeton.edu', user: 'deploy', roles: %i[web app db worker]
server 'catalog3.princeton.edu', user: 'deploy', roles: %i[web app db worker]
server 'catalog4.princeton.edu', user: 'deploy', roles: %i[web app db worker]
server 'catalog5.princeton.edu', user: 'deploy', roles: %i[web app db worker]
server 'catalog-indexer1.princeton.edu', user: 'deploy', roles: %i[cron_prod1 cron_db worker indexer]
server 'catalog-indexer2.princeton.edu', user: 'deploy', roles: %i[cron_prod2 worker indexer]
server 'catalog-indexer3.princeton.edu', user: 'deploy', roles: %i[cron_prod3 worker indexer]

set :deploy_to, '/opt/orangelight'
set :log_level, :info
