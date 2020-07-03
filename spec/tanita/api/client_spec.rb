# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'spec_helper'

Client = Tanita::Api::Client

RSpec.describe Tanita::Api::Client do
  before(:context) do
    WebMock.allow_net_connect!
  end

  it 'has a version number' do
    expect(Client::VERSION).not_to be nil
  end

  describe 'Tanita::Api::Client::Auth Helper' do
    it 'raise Error when initialize Auth class for insufficient parameters' do
      expect { Client::Auth.new }.to raise_error(Client::Error)
    end

    it 'set configuration for oauth' do
      Client.configure do |c|
        c.client_id = 'hoge_client_id'
        c.client_secret = 'hoge_client_secret'
        c.redirect_uri = 'hoge_redirect_uri'
        c.scopes = [Client::Scope::INNERSCAN]
      end
      expect(Client.configuration.client_id).to eq 'hoge_client_id'
      expect(Client.configuration.client_secret).to eq 'hoge_client_secret'
      expect(Client.configuration.redirect_uri).to eq 'hoge_redirect_uri'
      expect(Client.configuration.scopes).to eq [Client::Scope::INNERSCAN]
      Client::Auth.new
    end

    it 'generate valid auth uri' do
      auth_helper = Client::Auth.new
      expected_uri = "#{Client::AUTH_URL}?client_id=hoge_client_id&redirect_uri=hoge_redirect_uri&scope=innerscan&response_type=code"
      expect(auth_helper.auth_uri).to eq expected_uri
    end

    it 'raise Error when exchange access token by invalid auth code' do
      auth_helper = Client::Auth.new
      body = read_fixture('exchange_token', 'invalid.json')
      WebMock.stub_request(:post, Client::TOKEN_URL.to_s).to_return(:body => body)
      expect { auth_helper.exchange_token(:auth_code => 'invalid_code') }.to raise_error(Client::Error)
    end

    it 'exchange access token by valid auth code' do
      auth_helper = Client::Auth.new
      body = read_fixture('exchange_token', 'valid.json')
      WebMock.stub_request(:post, Client::TOKEN_URL.to_s).to_return(:body => body)
      expected_token = {:access_token => 'hoge_access_token', :expires_in => 12_345_678, :refresh_token => 'hoge_refresh_token'}
      expect(auth_helper.exchange_token(:auth_code => 'valid_code')).to eq expected_token
    end
  end

  describe 'Tanita::Api::Client::<SERVICE> Client' do
    it 'raise Error when initialize Service class for insufficient parameters' do
      expect { Client::Innerscan.new }.to raise_error(Client::Error)
    end

    it 'raise Error when initialize Service class for invalid parameters' do
      expect { Client::Innerscan.new(:date_type => 'unknown') }.to raise_error(Client::Error)
    end

    it 'set configuration for access_token' do
      expect { Client::Innerscan.new }.to raise_error(Client::Error)
      Client.configure do |c|
        c.access_token = 'hoge_token'
      end
      expect(Client.configuration.access_token).to eq 'hoge_token'
      Client::Innerscan.new
      Client::Sphygmomanometer.new
      Client::Pedometer.new
      Client::Smug.new
    end

    it 'raise Error invalid token' do
      innerscan = Client::Innerscan.new
      body = read_fixture('services', 'invalid_token.html')
      WebMock.stub_request(:post, "#{Client::BASE_URL}/status/innerscan.json").to_return(:body => body)
      expect { innerscan.status }.to raise_error(Client::Error)
    end

    it 'define Result.properties' do
      expected = %i[birth_date height sex items].sort
      actual = Client::Result.properties.sort
      expect(actual).to eq expected
    end

    it 'define InnerscanItem.properties' do
      expected = %i[measured_at registered_at model weight body_fat muscle_mass physique_rating visceral_fat_rating basal_metabolic_rate metabolic_age bone_mass].sort
      actual = Client::InnerscanItem.properties.sort
      expect(actual).to eq expected
    end

    it 'define PedometerItem.properties' do
      expected = %i[measured_at registered_at model steps exercise calories].sort
      actual = Client::PedometerItem.properties.sort
      expect(actual).to eq expected
    end

    it 'define SphygmomanometerItem.properties' do
      expected = %i[measured_at registered_at model maximal_pressure minimal_pressure pulse].sort
      actual = Client::SphygmomanometerItem.properties.sort
      expect(actual).to eq expected
    end

    it 'define SmugItem.properties' do
      expected = %i[measured_at registered_at model urinary_sugar].sort
      actual = Client::SmugItem.properties.sort
      expect(actual).to eq expected
    end

    it 'fetch Innerscan data' do
      api = Client::Innerscan.new
      body = read_fixture('services', 'innerscan_valid.json')
      WebMock.stub_request(:post, "#{Client::BASE_URL}#{api.class.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq Date.parse('20200101')
      expect(result.height).to eq 195.5
      expect(result.sex).to eq 'male'
      expected_items = [
        {
          :registered_at => nil,
          :measured_at => to_unixtime('201912050838'),
          :model => '01000144',
          :weight => 77.10,
          :body_fat => 21.30,
          :muscle_mass => 57.50,
          :physique_rating => 2,
          :visceral_fat_rating => 10.5,
          :basal_metabolic_rate => 1721,
          :metabolic_age => 32,
          :bone_mass => 3.10
        },
        {
          :registered_at => nil,
          :measured_at => to_unixtime('201912070806'),
          :model => '01000144',
          :weight => 76.70,
          :body_fat => 22.80,
          :muscle_mass => 56.20,
          :physique_rating => 2,
          :visceral_fat_rating => 11.0,
          :basal_metabolic_rate => 1680,
          :metabolic_age => 34,
          :bone_mass => 3.10
        }
      ]
      expect(result.items.map(&:to_h)).to eq expected_items
      expect(result.items[0].weight).to eq 77.10
    end

    it 'fetch Sphygmomanometer data' do
      api = Client::Sphygmomanometer.new(:date_type => Client::DATE_TYPE_REGISTERD_AT)
      body = read_fixture('services', 'sphygmomanometer_valid.json')
      WebMock.stub_request(:post, "#{Client::BASE_URL}#{api.class.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq Date.parse('20200101')
      expect(result.height).to eq 196.5
      expect(result.sex).to eq 'female'
      expected_items = [
        {
          :registered_at => to_unixtime('202001070115'),
          :measured_at => nil,
          :model => '00000000',
          :maximal_pressure => 180,
          :minimal_pressure => 70,
          :pulse => 20
        },
        {
          :registered_at => to_unixtime('202001070130'),
          :measured_at => nil,
          :model => '00000000',
          :maximal_pressure => 130,
          :minimal_pressure => 80,
          :pulse => 50
        }
      ]
      expect(result.items.map(&:to_h)).to eq expected_items
      expect(result.items[0].pulse).to eq 20
    end

    it 'fetch Pedometer items' do
      api = Client::Pedometer.new
      body = read_fixture('services', 'pedometer_valid.json')
      WebMock.stub_request(:post, "#{Client::BASE_URL}#{api.class.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq Date.parse('20200101')
      expect(result.height).to eq 197.5
      expect(result.sex).to eq 'male'
      expected_items = [
        {
          :registered_at => nil,
          :measured_at => to_unixtime('202001070000'),
          :model => '00000000',
          :steps => 1000,
          :exercise => nil,
          :calories => 5500
        },
        {
          :registered_at => nil,
          :measured_at => to_unixtime('202001080000'),
          :model => '00000000',
          :steps => 2222,
          :exercise => nil,
          :calories => 6660
        }
      ]
      expect(result.items.map(&:to_h)).to eq expected_items
      expect(result.items[0].steps).to eq 1000
    end

    it 'fetch Smug data' do
      api = Client::Smug.new
      body = read_fixture('services', 'smug_valid.json')
      WebMock.stub_request(:post, "#{Client::BASE_URL}#{api.class.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq Date.parse('20200101')
      expect(result.height).to eq 198.5
      expect(result.sex).to eq 'male'
      expected_items = [
        {
          :registered_at => nil,
          :measured_at => to_unixtime('202001070120'),
          :model => '00000000',
          :urinary_sugar => 500
        },
        {
          :registered_at => nil,
          :measured_at => to_unixtime('202001070125'),
          :model => '00000000',
          :urinary_sugar => 550
        }
      ]
      expect(result.items.map(&:to_h)).to eq expected_items
      expect(result.items[0].urinary_sugar).to eq 500
    end
  end

  after(:context) do
    WebMock.disable_net_connect!
  end

  def to_unixtime(str)
    Time.parse("#{str} +09:00").to_i
  end
end
