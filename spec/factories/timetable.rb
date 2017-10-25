FactoryGirl.define do
  today = Time.zone.today
  now = Time.now
  day_after_moon_landing = Date.parse('1969-07-21')
  factory :butler_today, class: Timetable do
    date        today
    open        Time.zone.parse('09:00', today.to_time)
    close       Time.zone.parse('17:00', today.to_time)
    association :location, factory: :butler, strategy: :find_or_create
  end

  factory :underbutler_today, class: Timetable do
    date        today
    open        Time.zone.parse('10:00', today.to_time)
    close       Time.zone.parse('16:00', today.to_time)
    association :location, factory: :underbutler, strategy: :find_or_create
  end

  factory :duanereade_today, class: Timetable do
    date        today
    open        Time.zone.parse('10:00', today.to_time)
    close       Time.zone.parse('10:00', today.next_day.to_time)
    association :location, factory: :duanereade, strategy: :find_or_create
  end

  factory :lehman_today, class: Timetable do
    date        today
    open        Time.zone.parse('08:00', today.to_time)
    close       Time.zone.parse('20:00', today.to_time)
    association :location, factory: :lehman, strategy: :find_or_create
  end

  factory :miskatonic_today, class: Timetable do
    date        today
    open        Time.zone.parse('18:00', today.to_time)
    close       Time.zone.parse('06:00', (today + 1.day).to_time)
    association :location, factory: :miskatonic, strategy: :find_or_create
  end

  factory :the_five_days_after_moon_landing, class: Timetable do
    sequence(:date) { |n| day_after_moon_landing + (n-1)%5 }
    open        Time.zone.parse('09:00', today.to_time)
    close       Time.zone.parse('17:00', today.to_time)
    sequence(:notes) { |n| "Day #{(n-1)%5}!" }
    closed      false
  end

  factory :butler_open_now, class: Timetable do
    date        today
    open        Time.zone.local(now.year, now.month, now.day,
                                now.hour - 2, 0, 0)
    close       Time.zone.local(now.year, now.month, now.day,
                                now.hour + 2, 0, 0)
    association :location, factory: :butler, strategy: :find_or_create
  end

  factory :butler_closed_now, class: Timetable do
    date        today
    open        Time.zone.local(now.year, now.month, now.day,
                                now.hour - 4, 0, 0)
    close       Time.zone.local(now.year, now.month, now.day,
                                now.hour - 2, 0, 0)
    association :location, factory: :butler, strategy: :find_or_create
  end

  factory :miskatonic_open_now, class: Timetable do
    date        today
    open        Time.zone.local(now.year, now.month, now.day,
                                now.hour - 2, 0, 0)
    close       Time.zone.local(now.year, now.month, now.day,
                                now.hour + 2, 0, 0)
    association :location, factory: :miskatonic, strategy: :find_or_create
  end

  factory :miskatonic_closed_now, class: Timetable do
    date        today
    open        Time.zone.local(now.year, now.month, now.day,
                                now.hour - 4, 0, 0)
    close       Time.zone.local(now.year, now.month, now.day,
                                now.hour - 2, 0, 0)
    association :location, factory: :miskatonic, strategy: :find_or_create
  end

  factory :lehman_closed_now, class: Timetable do
    date        today
    open        Time.zone.local(now.year, now.month, now.day,
                                now.hour - 4, 0, 0)
    close       Time.zone.local(now.year, now.month, now.day,
                                now.hour - 2, 0, 0)
    association :location, factory: :lehman, strategy: :find_or_create
  end
end
