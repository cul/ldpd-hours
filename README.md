# LDPD-Hours

[![Build Status](https://travis-ci.org/cul/ldpd-hours.svg?branch=master)](https://travis-ci.org/cul/ldpd-hours)

## Testing

Run rspec testing suite with `bundle exec rspec`

To run system tests which use Capybara run the following:

```
rake db:seed RAILS_ENV=test
rails test:system
```
