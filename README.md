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
- `$ rake db:seed`

   Seeds the db with two locations and an administrative user. Administrative credentials are:
   ```
   name: Test User
   email: admin@example.com
   ```
- `$ rails s`
- Navigate to `localhost:3000`


## Testing

You need to install chromedriver for javascript tests.

With Homebrew: `brew cask install chromedriver`

And on macOS Catalina (10.15) and later, you'll need to update security settings to allow chromedriver to run because the first-time run will tell you that "the developer cannot be verified."  See: https://stackoverflow.com/a/60362134

Then run the test suite with:

```
bundle exec rspec
```

## Notes

Because updating our hours uses a MySQL specific flavor of a batch upsert, if the db provider changes in the future you will need to modify the `TimeTable.batch_update_or_create` method with SQL appropriate for the db provider.

## Configuration
#### secrets.yml

Configuring `analytics_key` will cause the public layout to include the GA analytics snippet if the Rails environment config also has `track_users` set to true.


## Permissions
#### Editors
  For a specific calendar:
  - can change time information
  - can edit notes and url for calendar

#### Manager
- can do everything an Editor can do, for all locations
- can add/delete Editor
- can assign Editors to locations

#### Administrator
- can do everything a Manager can do
- can edit all user permissions (Can create editors, managers and administrators)
- can create/delete locations
- can edit location metadata (comments, url, name, primary location)

## API
### `GET api/v1/locations/:location_code`
#### Query Params
 - location_code: Location code
 - date: valid params are `today` or a date in `YYYY-MM-DD` format following the `w3cdtf` specification.
 - start_date: For a range of dates, provide a start date in `YYYY-MM-DD` format
 - end_date: For a range of date, provide an end date in `YYYY-MM-DD` format
#### Query Restrictions
 - start_date and end_date params can be no more than one year apart

#### Response Examples
##### `GET api/v1/locations/avery?date=today`
```
{
    "error" : null,
    "data" :
    {
	"butler" :
	[
	    {
		"date" : "2017-07-23",
		"open_time" : "09:00",
		"close_time" : "17:00",
		"closed" : false,
		"tbd" : false,
		"note" : "Free Donuts!",
		"formatted_date" : "09:00AM-05:00PM"
	    }
	]
    }
}
```

##### `GET api/v1/locations/:location_code?start_date=2017-09-27&end_date=2017-09-29`

```
{
    "error" : null,
    "data" :
    {
	"butler" :
	[
	    {
		"date" : "2017-07-24",
		"open_time" : "09:00",
		"close_time" : "17:00",
		"closed" : false,
		"tbd" : false,
		"note" : "Movie night!",
		"formatted_date" : "09:00AM-05:00PM"
	    }
	    ,
	    {
		"date" : "2017-07-25",
		"open_time" : "09:00",
		"close_time" : "17:00",
		"closed" : false,
		"tbd" : false,
		"note" : "",
		"formatted_date" : "09:00AM-05:00PM"
	    }
	    ,
            {
		"date" : "2017-07-26",
		"open_time" : null,
		"close_time" : null,
		"closed" : false,
		"tbd" : true,
		"note" : "",
		"formatted_date" : "TBD"
            }
	]
    }
}
```

A few notes about the above JSON structure:

- The last date entry is an example of the default date values that are returned for a date that does not have any associated data in Hours manager. So, in the above example, there was no information in the hours manager database for 07/26/2017 for location butler, and therefore default values were returned for that date.
- The middle date entry has an empty string value asociated with the "note" key. This is the default value (not null) if no note value was specified in the database for that date entry for the given location.

### `GET api/v1/locations/open_now`
#### Query Params
     None
#### Response Example
##### `GET api/v1/locations/open_now`
```
{
    "error" : null,
    "data" :
    {
	"butler" :
	{
	    "open_time" : "09:00",
	    "close_time" : "22:00",
	    "formatted_date" : "Until 10:00PM"
	}
	,
	"avery" :
	{
	    "open_time" : "09:00",
	    "close_time" : "22:00",
	    "formatted_date" : "Until 10:00PM"
	}
    }
}
```
