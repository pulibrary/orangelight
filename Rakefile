# frozen_string_literal: true

require File.expand_path('config/application', __dir__)

require 'rubocop/rake_task'
require 'solr_wrapper/rake_task'
require 'honeybadger/init/ruby'
require 'sneakers/tasks'

Rails.application.load_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run test suite and style checker'
task spec: :rubocop

Rake::Task[:default].clear
task default: :ci
