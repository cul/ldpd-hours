require 'csv'


namespace :legacy do
  # the CSVs in these tasks are mysql exports from the legacy db
  namespace :locations do
    task migrate: :environment do
      delete = %w[ccoh engineering engineering-reference lehman-suite]
      primary = %w[avery butler business lehman eastasian geology health-sciences law math music science-engineering social-work]
      primary.freeze
      irregular = {
        'rbml' => 'butler',
        'lio' => 'butler',
        'pmrr' => 'butler',
        'dhc' => 'butler',
        'ill' => 'butler',
        'studio-butler' => 'butler',
        'dssc-reference' => 'lehman',
        'lehman-suite' => 'social-work',
        'geologyref' => 'geology'
      }
      locations = CSV.table("db/seeds/library_data.csv").select { |row| !delete.include?(row[:lib_code])}
      primaries, secondaries = locations.partition { |location| primary.include?(location[:lib_code]) }

      csv_fields = %w[lib_name,lib_code,lib_comment,lib_url,lib_comment_below,lib_summary_tag]
      sql_fields = %w[name,code,comment,url,comment_two,summary]
      create_or_update = Proc.new do |row|
        location = Location.find_by(code: row[:lib_code]) || Location.new(code: row[:lib_code], created_at: Time.current)
        location.name = row[:lib_name]
        location.url = row[:lib_url]
        location.comment = row[:lib_comment]
        location.comment_two = row[:lib_comment_below]
        location.summary = row[:lib_summary_tag]
        primary_location = primary.include?(row[:lib_code])
        location.primary = primary_location
        unless primary_location
          primary_location_code = irregular[row[:lib_code]]
          primary_location_code ||= row[:lib_code].split('-')[0...-1].join('-')
          if primary_location_code.present? && primary_location_code != row[:lib_code]
            if primary.include?(primary_location_code)
              location.primary_location = Location.find_by(code: primary_location_code)
            end
          end
        end
        if location.save
          puts "updated #{location.code}"
        else
          puts "failed to update #{location.code}"
          puts location.errors.inspect
        end
      end
      primaries.each &create_or_update
      secondaries.each &create_or_update
    end
  end
  namespace :timetables do
    task migrate: :environment do
      calendars = CSV.table("db/seeds/calendars.csv")
      delete = %w[ccoh engineering engineering-reference]
      location_ids = {}
      warned = []
      Location.all.each do |location|
        location_ids[location.code] = location.id
      end
      calendars.each do |calendar|
        location_id = location_ids[ calendar[:cal_library] ]
        unless location_id || warned.include?(calendar[:cal_library])
          puts "warning: #{calendar[:cal_library]} not a location"
          warned << calendar[:cal_library]
        end
        next unless location_id
        cal_date = calendar[:cal_date]
        date = Date.parse(calendar[:cal_date])
        params = {location_id: location_id, date: date}
        timetable = Timetable.find_by(params) || Timetable.new(params)
        cal_open = calendar[:cal_open]
        cal_close = calendar[:cal_close]
        if timetable.closed || (cal_open.nil? && cal_close.nil?)
          timetable.closed = true
        else
          timetable.closed = false
          redeye = cal_close < cal_open # after midnight
          date_params = cal_date.split('-').map(&:to_i) + [12,0,0]
          open_hour, open_minute, open_second = cal_open.split(':').map(&:to_i)
          open = DateTime.new(*date_params).in_time_zone
          open = open.change(hour: open_hour, minute: open_minute)
          timetable.open = open
          close_hour, close_minute, close_second = cal_close.split(':').map(&:to_i)
          
          close = DateTime.new(*date_params).in_time_zone
          close = close + 1.day if redeye
          close = close.change(hour: close_hour, minute: close_minute)
          timetable.close = close
        end
        timetable.note = calendar[:day_notes]
        timetable.save
      end
    end
  end
  namespace :users do
    task migrate: :environment do
      roles = {
        "edit" => Permission::EDITOR,
        "super" => Permission::ADMINISTRATOR,
        "admin" => Permission::ADMINISTRATOR
      }
      location_ids = {}
      Location.all.each do |location|
        location_ids[location.code] = location.id
      end
      permissions = {}
      CSV.table("db/seeds/permissions.csv").each do |permission|
        uid = permission[:perm_user_name]
        code = permission[:perm_lib_id]
        user_permissions = (permissions[uid] ||= [])
        user_permissions << code if location_ids[code]
      end
      CSV.table("db/seeds/users.csv").each do |row|
        uid = row[:user_uname]
        name = row[:user_name]
        role = roles[row[:user_perm_level]]
        user_params = { uid: uid, provider: 'saml' }
        user = User.find_by(user_params) || User.new(user_params)
        user.name = name
        user.email = "#{uid}@columbia.edu"
        if user.save
          puts "updating permissions for #{uid}"
          permission_params = {
            role: role,
            location_ids: permissions.fetch(uid, []).map { |x| location_ids[x] }
          }
          user.update_permissions(permission_params)
          user.save
        else
          puts "could not update user #{uid}"
        end
      end
    end
  end
end