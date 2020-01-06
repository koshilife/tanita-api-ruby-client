# frozen_string_literal: true

require 'spec_helper'

Client = Tanita::Api::Client
TANITA_HOST = Client::HttpHelper::BASE_URL

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
      expected_uri = 'https://www.healthplanet.jp/oauth/auth?client_id=hoge_client_id&redirect_uri=hoge_redirect_uri&scope=innerscan&response_type=code'
      expect(auth_helper.auth_uri).to eq expected_uri
    end

    it 'raise Error when exchange access token by invalid auth code' do
      auth_helper = Client::Auth.new
      body = read_fixture('exchange_token', 'invalid.json')
      WebMock.stub_request(:post, "#{TANITA_HOST}/oauth/token").to_return(:body => body)
      expect { auth_helper.exchange_token(:auth_code => 'invalid_code') }.to raise_error(Client::Error)
    end

    it 'exchange access token by valid auth code' do
      auth_helper = Client::Auth.new
      body = read_fixture('exchange_token', 'valid.json')
      WebMock.stub_request(:post, "#{TANITA_HOST}/oauth/token").to_return(:body => body)
      expected_token = {:access_token => 'hoge_access_token', :expires_in => 12_345_678, :refresh_token => 'hoge_refresh_token'}
      expect(auth_helper.exchange_token(:auth_code => 'valid_code')).to eq expected_token
    end
  end

  describe 'Tanita::Api::Client::<SERVICE> Client' do
    it 'raise Error when initialize Service class for insufficient parameters' do
      expect { Client::Innerscan.new }.to raise_error(Client::Error)
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
      WebMock.stub_request(:post, "#{TANITA_HOST}/status/innerscan.json").to_return(:body => body)
      expect { innerscan.status }.to raise_error(Client::Error)
    end

    it 'fetch Innerscan data' do
      api = Client::Innerscan.new
      body = read_fixture('services', 'innerscan_valid.json')
      WebMock.stub_request(:post, "#{TANITA_HOST}#{api.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq '20200101'
      expect(result.height).to eq '198'
      expect(result.sex).to eq 'male'
      expected_data = [
        {
          :date => '201912050838',
          :model => '01000144',
          :weight => '77.10',
          :body_fat => '21.30',
          :muscle_mass => '57.50',
          :physique_rating => '2',
          :visceral_fat_rating2 => '10.5',
          :basal_metabolic_rate => '1721',
          :metabolic_age => '32',
          :bone_mass => '3.10'
        },
        {
          :date => '201912070806',
          :model => '01000144',
          :weight => '76.70',
          :body_fat => '22.80',
          :muscle_mass => '56.20',
          :physique_rating => '2',
          :visceral_fat_rating2 => '11.0',
          :basal_metabolic_rate => '1680',
          :metabolic_age => '34',
          :bone_mass => '3.10'
        }
      ]
      expect(result.data).to eq expected_data
    end

    it 'fetch Sphygmomanometer data' do
      api = Client::Sphygmomanometer.new
      body = read_fixture('services', 'sphygmomanometer_valid.json')
      WebMock.stub_request(:post, "#{TANITA_HOST}#{api.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq '20200101'
      expect(result.height).to eq '198'
      expect(result.sex).to eq 'male'
      expected_data = [
        {
          :date => '202001070115',
          :model => '00000000',
          :maximal_pressure => '180',
          :minimal_pressure => '70',
          :pulse => '20'
        },
        {
          :date => '202001070130',
          :model => '00000000',
          :maximal_pressure => '130',
          :minimal_pressure => '80',
          :pulse => '50'
        }
      ]
      expect(result.data).to eq expected_data
    end

    it 'fetch Pedometer data' do
      api = Client::Pedometer.new
      body = read_fixture('services', 'pedometer_valid.json')
      WebMock.stub_request(:post, "#{TANITA_HOST}#{api.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq '20200101'
      expect(result.height).to eq '198'
      expect(result.sex).to eq 'male'
      expected_data = [
        {
          :date => '202001070000',
          :model => '00000000',
          :steps => '1000',
          :calories => '5500'
        },
        {
          :date => '202001080000',
          :model => '00000000',
          :steps => '2222',
          :calories => '6660'
        }
      ]
      expect(result.data).to eq expected_data
    end

    it 'fetch Smug data' do
      api = Client::Smug.new
      body = read_fixture('services', 'smug_valid.json')
      WebMock.stub_request(:post, "#{TANITA_HOST}#{api.endpoint}").to_return(:body => body)
      result = api.status

      expect(result.birth_date).to eq '20200101'
      expect(result.height).to eq '198'
      expect(result.sex).to eq 'male'
      expected_data = [
        {
          :date => '202001070120',
          :model => '00000000',
          :urinary_sugar => '500'
        },
        {
          :date => '202001070125',
          :model => '00000000',
          :urinary_sugar => '550'
        }
      ]
      expect(result.data).to eq expected_data
    end
  end

  after(:context) do
    WebMock.disable_net_connect!
  end
end
