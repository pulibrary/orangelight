# frozen_string_literal: true

set :rvm_ruby_string, :local # use the same ruby as used locally for deployment
set :rails_env, 'alma_qa'
set :branch, ENV['BRANCH'] || 'main'

server 'catalog-qa1.princeton.edu', user: 'deploy', roles: %i[web app db worker mailcatcher cron_db]

namespace :env do
  desc 'Set an Orangelight environment variable'
  task :set do |_task, args|
    on roles(:app) do
      abort "Environment variables and values must be specified. `env:set['ENV_VAR=value']`" if args.extras.empty?
      config_file = '/home/deploy/app_configs/orangelight'
      args.extras.each do |arg|
        variable, value = arg.split('=', 2)
        abort "Environment variable and value must be specified. `env:set['ENV_VAR=value']`" if value.nil?
        within release_path do
          execute("sed -i -e 's/#{variable}=.*/#{variable}=#{value.gsub('/', '\/')}/' #{config_file}")
        end
      end

      # Print out app_config file
      within release_path do
        execute :cat, config_file
      end

      # Restart passenger
      invoke 'deploy:restart'
    end
  end

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
