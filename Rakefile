# frozen_string_literal: true

require File.expand_path('../config/application', __FILE__)

require 'rubocop/rake_task' if Rails.env.development? || Rails.env.test?
require 'honeybadger/init/ruby'
require 'sneakers/tasks'

Rails.application.load_tasks

if defined? RuboCop
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.requires << 'rubocop-rspec'
    task.fail_on_error = true
  end

  desc 'Run test suite and style checker'
  task spec: :rubocop
end
