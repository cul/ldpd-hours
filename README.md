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

## Permissions (as they currently are implemented in the original hours app)
### Admins
- For all libraries:
  - can edit comments, display name and URL (but not code)
  - can edit all times
- Can add/delete users
- Can edit what libraries a user can edit

### Supervisor
- For an assigned library:
  - can edit all times
  - can edit comments
  - can change what users can edit the library
  
### Contributor
- For an assigned library:
  - can edit all times
  - can edit comments
