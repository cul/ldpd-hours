FactoryGirl.define do
  factory :butler, class: Location do
    code 'butler'
    name 'Butler'
  end

  factory :lehman, class: Location do
    code 'lehman'
    name 'Lehman'
  end
end
