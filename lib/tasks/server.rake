# frozen_string_literal: true

namespace :yarn do
  desc 'Run jest tests'
  task :test do
    sh('yarn', 'test') if Rails.env.test? || Rails.env.development?
  end
end

namespace :servers do
  task initialize: :environment do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["pulsearch:solr:index"].invoke
    Rake::Task["browse:all"].invoke
    Rake::Task["browse:load_all"].invoke
  end

  desc "Start the Apache Solr and PostgreSQL container services using Lando."
  task start: :environment do
    Rake::Task["pulsearch:solr:update"].invoke
    system("lando start")
    system("rake servers:initialize")
    system("rake servers:initialize RAILS_ENV=test")
  end

  desc "Stop the Lando Apache Solr and PostgreSQL container services."
  task stop: :environment do
    system("lando stop")
  end

  desc "Index new fixtures and setup browse lists"
  task index_fixtures: :environment do
    Rake::Task["pulsearch:solr:index"].invoke
    Rake::Task["browse:all"].invoke
    Rake::Task["browse:load_all"].invoke
  end
end

namespace :server do
  desc 'Run development solr'
  task :dev do
    Rake::Task['pulsearch:solr:index'].invoke
    puts("Indexing to Lando. Running at http://localhost:#{ENV['lando_orangelight_development_solr_conn_port']}")
  end

  desc 'Run test solr'
  task :test do
    if Rails.env.test?
      Rake::Task['pulsearch:solr:index'].invoke
      puts("Indexing to Lando. Running at http://localhost:#{ENV['lando_orangelight_test_solr_conn_port']}")
    else
      system('rake server:test RAILS_ENV=test')
    end
  end
end
