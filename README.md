# Tanita::Api::Client

[![Test](https://github.com/koshilife/tanita-api-ruby-client/workflows/Test/badge.svg)](https://github.com/koshilife/tanita-api-ruby-client/actions?query=workflow%3ATest)
[![Gem Version](https://badge.fury.io/rb/tanita-api-client.svg)](http://badge.fury.io/rb/tanita-api-client)
[![license](https://img.shields.io/github/license/koshilife/tanita-api-ruby-client)](https://github.com/koshilife/tanita-api-ruby-client/blob/master/LICENSE.txt)

## About

These client libraries are created for [Tanita Health Planet](https://www.healthplanet.jp/) APIs.

refs: [Health Planet API Doc](https://www.healthplanet.jp/apis/api.html) (only Japanese)

### Setup

There are a few setup steps you need to complete before you can use this library:

1. If you don't already have a Health Planet account, [sign up](https://www.healthplanet.jp/entry_agreement.do).
2. If you have never created a developer application, read the [API Settings page](https://www.healthplanet.jp/apis_account.do) and be enable API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tanita-api-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tanita-api-client

## Usage

### Usage OAuth Helper

The library needs to be configured with your account's OAuth settings which is available in your Health Planet Api Settings page.
Set `client_id` `client_secret` `redirect_uri` `scopes` to its value:

```ruby

# OAuth configuration using configure method
Tanita::Api::Client.configure do |config|
  config.client_id = '<YOUR_CLIENT_ID>'
  config.client_secret = '<YOUR_CLIENT_SECRET>'
  config.redirect_uri = 'http://your-redirect-uri'
  config.scopes = [Tanita::Api::Client::Scope::INNERSCAN]
end
auth_helper = Tanita::Api::Client::Auth.new

# OAuth configuration using initializer
auth_helper = Tanita::Api::Client::Auth.new(
  client_id: '<YOUR_CLIENT_ID>',
  client_secret: '<YOUR_CLIENT_SECRET>',
  redirect_uri: 'http://your-redirect-uri',
  scopes: Tanita::Api::Client::Scope.all
)
```

Below is the sample get an authentication url and exchange access token from an authentication code.

```ruby
# get Health Planet authentication url
auth_helper.auth_uri
=> "https://www.healthplanet.jp/oauth/auth?client_id=YOUR_ID&redirect_uri=http%3A%2F%2F127.0.0.1%2Fcallback&scope=innerscan&response_type=code"

# get access token
token = auth_helper.exchange_token(auth_code: '<AUTHENTICATION_CODE>')
=> {:access_token=>"hoge_access_token", :expires_in=>12345678, :refresh_token=>"hoge_refresh_token"}
```

### Usage Apis Client

The Api client needs access token.
Set `access_token` to the value you got by above:

```ruby
# using configure
Tanita::Api::Client.configure do |config|
  config.access_token = '<YOUR_ACCESS_TOKEN>'
end
api = Tanita::Api::Client::Innerscan.new

# using initializer
api = Tanita::Api::Client::Innerscan.new(access_token: '<YOUR_ACCESS_TOKEN>')

# fetch innerscan data
result = api.status

# you can specify a period using params(from:, to:)
result = api.status(from: Date.current.ago(1.month), to: Date.current)

# list the body-weight data
result.items.each{|item| puts "#{Time.at(item.measured_at).strftime('%F %R')} => #{item.weight}" }
2019-10-10 08:09 => 66.7
2019-10-11 09:02 => 66.5
2019-10-13 08:22 => 66.7
2019-10-15 08:49 => 66.4
2019-10-17 07:52 => 67.0

# Result of Innerscan Api
result = Tanita::Api::Client::Innerscan.new.status
=> #<Tanita::Api::Client::Result:70199592389780 properties=birth_date,height,sex,items>
result.items[0]
=> #<Tanita::Api::Client::InnerscanItem:70199597695880 properties=measured_at,registered_at,model,weight,body_fat,muscle_mass,physique_rating,visceral_fat_rating,basal_metabolic_rate,metabolic_age,bone_mass>
result.items[0].weight
=> 66.7

# Result of Sphygmomanometer Api
result = Tanita::Api::Client::Sphygmomanometer.new.status
result.items[0]
=> #<Tanita::Api::Client::SphygmomanometerItem:70199592475760 properties=measured_at,registered_at,model,maximal_pressure,minimal_pressure,pulse>

# Result of Pedometer Api
result = Tanita::Api::Client::Pedometer.new.status
result.items[0]
=> #<Tanita::Api::Client::PedometerItem:70199605021160 properties=measured_at,registered_at,model,steps,exercise,calories>


# Result of Smug Api
result = Tanita::Api::Client::Smug.new.status
result.items[0]
=> #<Tanita::Api::Client::SmugItem:70199600803680 properties=measured_at,registered_at,model,urinary_sugar>

# common attributes of Result class
result.birth_date # [Date]
result.height     # [Float] (centimeter)
result.sex        # [String] 'male' or 'female'
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/koshilife/tanita-api-ruby-client). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tanita::Api::Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/tanita-api-ruby-client/blob/master/CODE_OF_CONDUCT.md).
