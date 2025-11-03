# frozen_string_literal: true
desc 'Run microbenchmarks'
task benchmark: :environment do
  Dir[Rails.root.join('benchmarks/**/*.rb').to_s].each do |path|
    next if path.include? 'benchmark_helpers'
    require path
    puts "\n*******\n\n"
  end
end
