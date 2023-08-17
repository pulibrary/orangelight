# frozen_string_literal: true
namespace :announcement do
  desc 'Set text for announcement'
  task :set, [:text] => [:environment] do |_task, args|
    if Announcement.count.zero?
      Announcement.create!(text: args.text)
    else
      announcement = Announcement.first
      announcement.text = args.text
      announcement.save!
    end
    Rake::Task["announcement:show"].invoke
  end

  desc 'Show current text of announcement'
  task show: :environment do
    puts "The currently set text is: #{Announcement.first.text}"
    puts "The text will be displayed in the Catalog: #{Flipflop.message_display?}"
  end
end
