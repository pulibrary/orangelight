# frozen_string_literal: true

require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = "#{ENV['APPLICATION_HOST_PROTOCOL']}://#{ENV['APPLICATION_HOST']}" || 'http://localhost'
SitemapGenerator::Sitemap.create do
  add '/'

  add '/help'
  add '/feedback'
  add '/course_reserves'

  add '/advanced'

  cursor_mark = '*'
  loop do
    response = Blacklight.default_index.connection.get('select', params:
    {
      'q' => '*:*',
      'fl' => 'id',
      'cursorMark' => cursor_mark,
      'rows' => ENV['BATCH_SIZE'] || 1000,
      'sort' => 'id asc'
    })

    response['response']['docs'].each do |doc|
      add "/catalog/#{doc['id']}"
    end

    break if response['nextCursorMark'] == cursor_mark
    cursor_mark = response['nextCursorMark']
  end
end
SitemapGenerator::Sitemap.ping_search_engines
