FactoryGirl.define do
  factory :butler, class: Library do
    code 'butler'
    name 'Butler'
  end

  factory :lehman, class: Library do
    code 'lehman'
    name 'Lehman'
  end
end
