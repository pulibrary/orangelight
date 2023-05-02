# frozen_string_literal: true

FactoryBot.define do
  factory :bookmark do
    user { FactoryBot.create(:user) }
    document_id { "99125412083106421" }
    document_type { 'SolrDocument' }
  end
end
