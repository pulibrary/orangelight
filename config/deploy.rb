# config valid only for Capistrano 3.1
lock '>=3.2.1'

set :application, 'orangelight'
set :repo_url, 'https://github.com/pulibrary/orangelight.git'

# gets overriden to development on staging deploy
set :branch, 'master'

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
set :linked_dirs, %w{tmp/pids tmp/sockets}


# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :default_env, { path: "/home/vagrant/.rvm/gems/ruby-2.2.3/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

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

  task :robots_txt do
    on roles(:app) do
      within release_path do
        execute :rake, 'pulsearch:robots_txt'
      end
    end
  end
  after :publishing, :restart
  after :publishing, :robots_txt

  after :finishing, 'deploy:cleanup'
end
