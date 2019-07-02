# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RobotsGeneratorService do
  subject(:robots) { described_class.new(path: file.path, disallowed_paths: ['/path1', '/path2']) }

  let(:file) { Tempfile.new('robots.txt') }

  after do
    file.unlink
  end

  describe '.default' do
    let(:service_class) { class_double(described_class).as_stubbed_const(transfer_nested_constants: true) }
    let(:service) { instance_double(described_class) }
    let(:path) { Rails.root.join('public', 'robots.txt') }
    let(:disallowed_paths) { Rails.configuration.robots.disallowed_paths }

    before do
      allow(service_class).to receive(:new).and_return(service)
      allow(service).to receive(:insert_group)
      allow(service).to receive(:insert_crawl_delay)
      allow(service).to receive(:insert_sitemap)
      allow(service).to receive(:generate)
      allow(service).to receive(:write)
      described_class.default
    end

    it 'generates a robots.txt with the default settings' do
      expect(service_class).to have_received(:new).with(path: path, disallowed_paths: disallowed_paths)
      expect(service).to have_received(:insert_group).with(user_agent: '*')
      expect(service).to have_received(:insert_crawl_delay).with(10)
      expect(service).to have_received(:insert_sitemap).with('https://catalog.princeton.edu/sitemap.xml.gz')
      expect(service).to have_received(:generate)
      expect(service).to have_received(:write)
    end
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
