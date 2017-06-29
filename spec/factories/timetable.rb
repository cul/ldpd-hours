FactoryGirl.define do
  factory :butler_today, class: Timetable do
    date        Date.current
    open        '09:00'
    close       '17:00'
    association :location, factory: :butler
  end

  factory :lehman_today, class: Timetable do
    date        Date.current
    open        '08:00'
    close       '20:00'
    association :location, factory: :lehman
  end
end
