# LDPD-Hours

[![Build Status](https://travis-ci.org/cul/ldpd-hours.svg?branch=master)](https://travis-ci.org/cul/ldpd-hours)
[![Code Climate](https://codeclimate.com/github/cul/ldpd-hours/badges/gpa.svg)](https://codeclimate.com/github/cul/ldpd-hours)
[![Issue Count](https://codeclimate.com/github/cul/ldpd-hours/badges/issue_count.svg)](https://codeclimate.com/github/cul/ldpd-hours)
[![Coverage Status](https://coveralls.io/repos/github/cul/ldpd-hours/badge.svg?branch=master)](https://coveralls.io/github/cul/ldpd-hours?branch=master)

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