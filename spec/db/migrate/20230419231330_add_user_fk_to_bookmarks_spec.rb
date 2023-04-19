# frozen_string_literal: true

# TODO: remove this test, since it will be of
# limited value once the migration has been run

require 'rails_helper'
require 'rake'

Orangelight::Application.load_tasks
require Rails.root.join('db', 'migrate', '20230419231330_add_user_fk_to_bookmarks.rb')

RSpec.describe AddUserFkToBookmarks do
  self.use_transactional_tests = false
  let(:valid_user) { FactoryBot.create :valid_princeton_patron }
  before do
    rollback_described_migration
    ActiveRecord::Base.transaction do
      [valid_user.id, -1, 999_999_999].each do |user_id|
        (1..5).each do |document_id|
          bookmark = Bookmark.new
          bookmark.user_id = user_id
          bookmark.document_id = document_id
          bookmark.save
          begin
            User.find(user_id).bookmarks << bookmark
          rescue ActiveRecord::RecordNotFound
            'not a valid user'
          end
        end
      end
    end
  end
  it 'deletes bookmarks without a valid user' do
    expect { run_described_migration }.to change(Bookmark, :count).by(-10)
  end

  it 'does not delete bookmarks with a valid user' do
    expect(valid_user.reload.bookmarks.count).to eq 5
    expect { run_described_migration }.not_to change(valid_user.bookmarks, :count)
  end
  context 'after migration is applied' do
    it 'cleans up bookmarks when a user is deleted' do
      run_described_migration
      Bookmark.destroy_all
      bookmark = Bookmark.new
      bookmark.user_id = valid_user.id
      bookmark.document_id = 123_456
      bookmark.save
      expect { valid_user.destroy }.to change(Bookmark, :count).by(-1)
    end
  end
end

def run_described_migration
  system({ 'VERSION' => '20230419231330',
           'RAILS_ENV' => 'test' },
    'rake db:migrate:up')
end

def rollback_described_migration
  system({ 'VERSION' => '20230419231330',
           'RAILS_ENV' => 'test' },
          'rake db:migrate:down')
  Bookmark.reset_column_information
end
