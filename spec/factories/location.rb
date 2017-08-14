FactoryGirl.define do
  factory :butler, class: Location do
    code 'butler'
    name 'Butler'
    primary true
  end

  factory :underbutler, class: Location do
    code 'underb'
    name 'Library Under Butler'
    primary false
    association :primary_location, factory: :butler
  end

  factory :lehman, class: Location do
    code 'lehman'
    name 'Lehman'
    primary true
  end

  factory :miskatonic, class: Location do
    code 'miskat'
    name 'Miskatonic'
    primary true
  end

  factory :sorcery, class: Location do
    code 'sorcery'
    name 'Sorcery and Necromancy Library'
    primary false
    association :primary_location, factory: :miskatonic
  end
end
