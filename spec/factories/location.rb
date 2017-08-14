FactoryGirl.define do
  factory :butler, class: Location do
    code 'butler'
    name 'Butler'
  end

  factory :lehman, class: Location do
    code 'lehman'
    name 'Lehman'
  end

  factory :miskatonic, class: Location do
    code 'miskat'
    name 'Miskatonic'
  end
end
