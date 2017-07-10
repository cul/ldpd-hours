# LDPD-Hours

[![Build Status](https://travis-ci.org/cul/ldpd-hours.svg?branch=master)](https://travis-ci.org/cul/ldpd-hours)
[![Code Climate](https://codeclimate.com/github/cul/ldpd-hours/badges/gpa.svg)](https://codeclimate.com/github/cul/ldpd-hours)
[![Issue Count](https://codeclimate.com/github/cul/ldpd-hours/badges/issue_count.svg)](https://codeclimate.com/github/cul/ldpd-hours)
[![Coverage Status](https://coveralls.io/repos/github/cul/ldpd-hours/badge.svg?branch=display_hours)](https://coveralls.io/github/cul/ldpd-hours?branch=display_hours)

## Local Installation

- Git clone this repo
- Setup a MySQL db locally and add credentials to config/database.yml
- `$ bundle install`
- `$ rake db:migrate`
- If you don't have yarn currently installed please run `brew install yarn`
- `$ yarn`
- Navigate to `localhost:3000`


## Testing

Run testing suite with:

```
rake db:seed RAILS_ENV=test
bundle exec rspec
```

## Notes

Because updating our hours uses a MySQL specific flavor of a batch upsert, if the db provider changes in the future you will need to modify the `TimeTable.batch_update_or_create` method with SQL appropriate for the db provider.

## Permissions
### Editors
  For a specific calendar:
  - can change time information
  - can edit notes and url for calendar
 
### Manager
- can do everything an Editor can do, for all locations
- can add/delete Editor
- can assign Editors to locations
 
### Administrator
- can do everything a Manager can do
- can promote/demote Editors to Managers (can edit all user permissions)
- can create/delete locations
- can edit location metadata (comments, url, name, primary location)

## API
### `GET v1/locations/:location_code`
#### Query Params
 - location_code: Location code
 - date: date in YYYY-MM-DD format or `today`
        Date should be formated following the w3cdtf specification.

#### Response
##### Example 1:
      `GET /v1/locations/avery?date=today`
      
      ```
      {
        open_time: '',
        close_time: '',
        note_1: '',
        note_2: '',
        tbd: true/false,
        closed: true/false,
        formated_date: '',  
      }
      ```
      
      `GET v1/locations/:location_code?start_date=2017-09-30&end_date=2017-10-30`

### `GET v1/locations/open_now`
#### Query Params
     None
#### Response
     ```
     
     ```
     
