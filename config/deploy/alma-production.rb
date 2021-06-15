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

server 'catalog1', user: 'deploy', roles: %i[web app db]
server 'catalog2', user: 'deploy', roles: %i[web app db sitemap]
server 'catalog-indexer1', user: 'deploy', roles: %i[cron_prod1 cron_db]
server 'catalog-indexer2', user: 'deploy', roles: %i[cron_prod2]
server 'catalog-indexer3', user: 'deploy', roles: %i[cron_prod3]

set :deploy_to, '/opt/orangelight'
set :log_level, :info
