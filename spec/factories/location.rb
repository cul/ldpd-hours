FactoryBot.define do
  factory :butler, class: Location do
    code { 'butler' }
    name { 'Butler' }
    primary { true }
    primary_location { nil }
    short_note { 'This is a short note' }
    short_note_url { 'https://library.columbia.edu' }
  end

  factory :underbutler, class: Location do
    code { 'underb' }
    name { 'Library Under Butler' }
    primary { false }
    association :primary_location, factory: :butler, strategy: :find_or_create
  end

  factory :duanereade, class: Location do
    code { 'dreade' }
    name { 'Corner Drugstore' }
    primary { false }
    primary_location { nil }
  end

  factory :lehman, class: Location do
    code { 'lehman' }
    name { 'Lehman' }
    primary { true }
    primary_location { nil }
  end

  factory :miskatonic, class: Location do
    code { 'miskat' }
    name { 'Miskatonic' }
    primary { true }
    primary_location { nil }
  end

  factory :sorcery, class: Location do
    code { 'sorcer' }
    name { 'Sorcery and Necromancy Library' }
    primary { false }
    association :primary_location, factory: :miskatonic, strategy: :find_or_create
  end

  factory :butler_five_days, class: Location do
    code { 'butlerfivedays' }
    name { 'Butler Five Days' }
    primary { true }
    primary_location { nil }
    after :create do |t|
      create_list :the_five_days_after_moon_landing, 5, location: t
    end
  end

  factory :all_location, class: Location do
    code { 'all' }
    name { 'Magic Overwrite All Location' }
    primary { true }
    primary_location { nil }
  end
end
