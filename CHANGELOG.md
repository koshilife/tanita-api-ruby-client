
# 0.2.0

* set required ruby version to greater than or equal to v2.4
* added `data_type` argument in BaseApiClient#initialize
* set a proper data type in Result class attributes
* rename some attributes in Result class
  * e.g.
  * `@data` to `@items`
  * `@data[0][:date]` to `@items[0][:measured_at]` or `@items[0][:registered_at]`

# 0.1.1

* support Tanita::Api::Client.configure
* wrote spec

# 0.1.0

* Initial release
