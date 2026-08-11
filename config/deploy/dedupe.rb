# frozen_string_literal: true

set :rvm_ruby_string, :local # use the same ruby as used locally for deployment
set :rails_env, 'dedupe'
set :branch, ENV['BRANCH'] || 'main'

server 'catalog-dedupe1.princeton.edu', user: 'deploy', roles: %i[web app db worker mailcatcher cron_db]
server 'catalog-dedupe2.princeton.edu', user: 'deploy', roles: %i[web app worker mailcatcher]
server 'catalog-indexer-dedupe1.princeton.edu', user: 'deploy', roles: %i[cron_db worker indexer]
server 'catalog-indexer-dedupe2.princeton.edu', user: 'deploy', roles: %i[cron_db worker indexer]

  desc 'Set Orangelight to use figgy production'
  task :figgy_production do
    on roles(:app) do
      Rake::Task['env:set'].invoke('GRAPHQL_API_URL=https://figgy.princeton.edu/graphql', 'FIGGY_URL=https://figgy.princeton.edu')
    end
  end

  desc 'Set Orangelight to use figgy staging'
  task :figgy_staging do
    on roles(:app) do
      Rake::Task['env:set'].invoke('GRAPHQL_API_URL=https://figgy-staging.princeton.edu/graphql', 'FIGGY_URL=https://figgy-staging.princeton.edu')
    end
  end
end
