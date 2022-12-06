# frozen_string_literal: true
require 'rails_helper'

describe Bookmark do
  it 'does not allow user to create more than the maximum configured bookmarks' do
    user = FactoryBot.create(:user_with_many_bookmarks,
                             bookmarks: Orangelight.config['bookmarks']['maximum'])
    expect do
      bookmark = described_class.new(user:, document_id: '123')
      bookmark.save!
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end
