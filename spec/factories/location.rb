FactoryGirl.define do
  factory :butler, class: Location do
    code 'butler'
    name 'Butler'
    primary true
    primary_location nil
  end

  factory :underbutler, class: Location do
    code 'underb'
    name 'Library Under Butler'
    primary false
    association :primary_location, factory: :butler, strategy: :find_or_create
  end

  factory :lehman, class: Location do
    code 'lehman'
    name 'Lehman'
    primary true
    primary_location nil
  end

  factory :miskatonic, class: Location do
    code 'miskat'
    name 'Miskatonic'
    primary true
    primary_location nil
  end

  factory :sorcery, class: Location do
    code 'sorcer'
    name 'Sorcery and Necromancy Library'
    primary false
    association :primary_location, factory: :miskatonic, strategy: :find_or_create
  end
end
