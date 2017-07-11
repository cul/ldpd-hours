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
 - date: valid params are `today` or a date in `YYYY-MM-DD` format following the `w3cdtf` specification.
 - start_date: For a range of dates, provide a start date in `YYYY-MM-DD` format
 - end_date: For a range of date, provide an end date in `YYYY-MM-DD` format

#### Examples
```
GET /v1/locations/avery?date=today

{ 
  "avery": {
    "date": "2017-07-14",
    "open_time": "09:00",
    "close_time": "22:00",
    "note": "Intersession",
    "tbd": false,
    "closed": false,
    "formated_date": "9:00AM-10:00PM"
  }
}
```

Another possibility for the response, will leave to product owners to decide.

```
{ 
  "avery": {
    "2017-07-14": {
      "open_time": "09:00",
      "close_time": "22:00",
      "note": "Intersession",
      "tbd": false,
      "closed": false,
      "formated_date": "9:00AM-10:00PM"
  }
}
```

```
GET v1/locations/:location_code?start_date=2017-09-27&end_date=2017-09-29
{
  "avery": [
    {
      "date": "2017-09-27",
      "open_time": "09:00",
      "close_time": "22:00",
      "note": "Intersession",
      "tbd": false,
      "closed": false,
      "formated_date": "9:00AM-10:00PM"
    },
    {
      "date": "2017-09-28",
      "open_time": null,
      "close_time": null,
      "note": "Intersession",
      "tbd": false,
      "closed": true,
      "formated_date": "Closed"
    },
    {
      "date": "2017-09-29",
      "open_time": null,
      "close_time": null,
      "note": "Intersession",
      "tbd": true,
      "closed": false,
      "formated_date": "TBD"
    }
  ]
}
```

### `GET v1/locations/open_now`
#### Query Params
     None
#### Response
```
{
 "avery": {
   "open_time": "09:00",
   "close_time": "22:00",
   "formatted_date": "Until 10:00PM"
 },
 "butler": {
   "open_time": "09:00",
   "close_time": "17:00",
   "formatted_date": "Until 5:00PM"
 }     
}
```
     
