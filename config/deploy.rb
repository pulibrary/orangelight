# frozen_string_literal: true

# config valid only for Capistrano 3.1
lock '>=3.2.1'

set :application, 'orangelight'
set :repo_url, 'https://github.com/pulibrary/orangelight.git'

set :branch, ENV.fetch('BRANCH', 'main')

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/opt/orangelight'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true


shared_path = "#{:deploy_to}/shared"
# set :assets_prefix, '#{shared_path}/public'

## removing the following from linked files for the time being
# config/redis.yml config/devise.yml config/resque_pool.yml, config/recipients_list.yml, log/resque-pool.stderr.log log/resque-pool.stdout.log

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log tmp/pids tmp/sockets}

set :whenever_roles, ->{ [:cron_prod1, :cron_prod2, :cron_prod3, :sitemap, :cron_db] }


# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :default_env, { path: "/home/vagrant/.rvm/gems/ruby-x.x.x/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :passenger_restart_with_touch, true

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :publishing, :restart

  after :finishing, 'deploy:cleanup'

  # We shouldn't need this because it should be built in to Rails 5.1
  # see https://github.com/rails/webpacker/issues/1037
  desc 'Run yarn install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end
  before "deploy:assets:precompile", "deploy:yarn_install"
end

namespace :sneakers do
  task :restart do
    on roles(:worker) do
      execute :sudo, :service, 'orangelight-sneakers', :restart
    end
  end
end

namespace :cache do
  desc 'Run rake cache:clear'
  task :clear do
    on roles(:web) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, 'cache:clear'
        end
      end
    end
  end
end

namespace :smtp do
  desc 'Turn off mail catcher on staging'
  task :turn_off_mailcatcher do
    on roles(:mailcatcher) do
      execute :sed,"'s/^export\ SMTP_HOST=.*/export\ SMTP_HOST=lib-ponyexpr\.princeton\.edu/' app_configs/orangelight > app_configs/orangelight2"
      execute :sed,"'s/^export\ SMTP_PORT=.*/export\ SMTP_PORT=25/' app_configs/orangelight2 > app_configs/orangelight"
      execute :rm,"app_configs/orangelight2"
      invoke "deploy:restart"
    end
  end

  desc 'Turn on mail catcher on staging'
  task :turn_on_mailcatcher do
    on roles(:mailcatcher) do
      execute :sed,"'s/^export\ SMTP_HOST=.*/export\ SMTP_HOST=localhost/' app_configs/orangelight > app_configs/orangelight2"
      execute :sed,"'s/^export\ SMTP_PORT=.*/export\ SMTP_PORT=1025/' app_configs/orangelight2 > app_configs/orangelight"
      execute :rm,"app_configs/orangelight2"
      invoke "deploy:restart"
    end
  end
end

after 'deploy:reverted', 'sneakers:restart'
after 'deploy:published', 'sneakers:restart'
