FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "username#{srand}" }
    sequence(:email) { |n| "email-#{srand}@princeton.edu" }
    provider 'cas'
    password 'foobarfoo'
    uid do |user|
      user.username
    end

    factory :valid_princeton_patron do
    end

    factory :invalid_princeton_patron do
    end

    factory :unauthorized_princeton_patron do
    end

    # for patrons without a net ID
    factory :guest_patron do
      provider 'voyager'
      guest true
    end
  end
end
