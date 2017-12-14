require 'rails_helper'

RSpec.describe RobotsGeneratorService do
  subject(:robots) { described_class.new(path: file.path, disallowed_paths: ['/path1', '/path2']) }

  let(:file) { Tempfile.new('robots.txt') }

  after do
    file.unlink
  end

  describe '#disallow' do
    before do
      robots.disallow('/path3')
      robots.generate
      robots.write
    end
    it 'inserts a disallow directive' do
      expect(file.read).to include('Disallow: /path3')
    end
  end

  describe '#insert_group' do
    before do
      robots.insert_group(user_agent: 'test-bot')
      robots.generate
      robots.write
    end
    it 'inserts a disallow directive' do
      expect(file.read).to include('User-agent: test-bot')
    end
  end

  describe '#crawl_delay' do
    before do
      robots.insert_crawl_delay(99)
      robots.generate
      robots.write
    end
    it 'inserts a disallow directive' do
      expect(file.read).to include('Crawl-delay: 99')
    end
  end

  describe '#insert_sitemap' do
    before do
      robots.insert_sitemap('https://test.edu/sitemap.xml.gz')
      robots.generate
      robots.write
    end
    it 'inserts a disallow directive' do
      expect(file.read).to include('Sitemap: https://test.edu/sitemap.xml.gz')
    end
  end
end
