# 0.4.1

- refs #4 fix settings for simplecov.

# 0.4.0

- refs #4 measure code coverage
- refs #5 setup GitHub Actions for rspec and pushing to RubyGems

# 0.3.0

changed Result hash to be Object.

```
# before
result.items[0][:weight]
# after
result.items[0].weight
```

# 0.2.3

remove Gemfile.lock

# 0.2.2

- define constants
  - `Tanita::Api::Client::AUTH_URL`
  - `Tanita::Api::Client::AUTH_URL_PATH`
  - `Tanita::Api::Client::TOKEN_URL`
  - `Tanita::Api::Client::TOKEN_URL_PATH`

# 0.2.1

- rename constant
  - from `Tanita::Api::Client::HttpHelper::BASE_URL` to `Tanita::Api::Client::BASE_URL`

# 0.2.0

- set required ruby version to greater than or equal to v2.4
- added `data_type` argument in BaseApiClient#initialize
- set a proper data type in Result class attributes
- rename some attributes in Result class
  - e.g.
  - `@data` to `@items`
  - `@data[0][:date]` to `@items[0][:measured_at]` or `@items[0][:registered_at]`

# 0.1.1

- support Tanita::Api::Client.configure
- wrote spec

# 0.1.0

- Initial release
