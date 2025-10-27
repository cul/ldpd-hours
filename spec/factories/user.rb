FactoryBot.define do
  factory :admin, class: User do
    uid { 'abc123' }
    email { 'abc123@columbia.edu' }
    name { 'Abc 123' }
  end

  factory :user, class: User do
    uid { 'xyz123'}
    email { 'xyz123@columbia.edu' }
    name { 'Xyz 123' }
  end
end
