# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmark do
  it('cannot create a bookmark with an invalid user id') do
    bookmark1 = Bookmark.new user_id: -1, document_id: 123
    expect { bookmark1.save }.to raise_error(ActiveRecord::InvalidForeignKey)
  end
end
