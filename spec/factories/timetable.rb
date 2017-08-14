FactoryGirl.define do
  today = Time.zone.today
  factory :butler_today, class: Timetable do
    date        today
    open        Time.zone.parse('09:00', today.to_time)
    close       Time.zone.parse('17:00', today.to_time)
    association :location, factory: :butler
  end

  factory :lehman_today, class: Timetable do
    date        today
    open        Time.zone.parse('08:00', today.to_time)
    close       Time.zone.parse('20:00', today.to_time)
    association :location, factory: :lehman
  end

  factory :miskatonic_today, class: Timetable do
    date        today
    open        Time.zone.parse('18:00', today.to_time)
    close       Time.zone.parse('06:00', (today + 1.day).to_time)
    association :location, factory: :miskatonic
  end
end
