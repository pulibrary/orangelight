FactoryGirl.define do
  factory :user do
    sequence(:username) { "username#{srand}" }
    sequence(:email) { "email-#{srand}@princeton.edu" }
    provider 'cas'
    password 'foobarfoo'
    uid(&:username)

    factory :valid_princeton_patron do
    end

    factory :invalid_princeton_patron do
    end

    factory :unauthorized_princeton_patron do
    end

    # for patrons without a net ID
    factory :guest_patron do
      provider 'barcode'
    end
  end
end
