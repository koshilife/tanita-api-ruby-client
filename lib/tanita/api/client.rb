# frozen_string_literal: true

Dir[
  File.join(
    File.dirname(__FILE__),
    'client',
    '*'
  )
].sort.each { |f| require f }

module Tanita
  module Api
    module Client
      class << self
        def configure
          yield configuration
        end

        def configuration
          @configuration ||= Tanita::Api::Client::Configuration.new
        end
      end

      class Auth
        include HttpHelper

        def initialize(client_id: nil, client_secret: nil, redirect_uri: nil, scopes: nil)
          config = Tanita::Api::Client.configuration
          @client_id = client_id || config.client_id
          @client_secret = client_secret || config.client_secret
          @redirect_uri = redirect_uri || config.redirect_uri
          @scopes = scopes || config.scopes
          check_required_arguments
        end

        def auth_uri
          params = {
            :client_id => @client_id,
            :redirect_uri => @redirect_uri,
            :scope => @scopes.join(','),
            :response_type => 'code'
          }
          generate_uri(AUTH_URL_PATH, params)
        end

        def exchange_token(auth_code:)
          params = {
            :client_id => @client_id,
            :client_secret => @client_secret,
            :redirect_uri => DEFAULT_REDIRECT_URI,
            :code => auth_code,
            :grant_type => 'authorization_code'
          }
          res = request(TOKEN_URL_PATH, params)
          token = parse_json(res.body)

          raise Error.new("#{self.class}.#{__method__}: #{token[:error]}") if token.key? :error

          token
        end

      private

        def check_required_arguments
          raise Error.new("param:'client_id' is required.'") if @client_id.nil?
          raise Error.new("param:'client_secret' is required.'") if @client_secret.nil?
          raise Error.new("param:'redirect_uri' is required.'") if @redirect_uri.nil?
          raise Error.new("param:'scopes' is required.'") if @scopes.nil?
        end
      end

      class Innerscan < BaseApiClient
        def self.endpoint
          '/status/innerscan.json'
        end

        def self.properties
          {
            :weight => {:code => '6021', :type => Float},
            :body_fat => {:code => '6022', :type => Float},
            :muscle_mass => {:code => '6023', :type => Float},
            :physique_rating => {:code => '6024', :type => Integer},
            :visceral_fat_rating => {:code => '6025', :type => Float},
            :basal_metabolic_rate => {:code => '6027', :type => Integer},
            :metabolic_age =>  {:code => '6028', :type => Integer},
            :bone_mass =>  {:code => '6029', :type => Float}
          }
        end
      end

      class Sphygmomanometer < BaseApiClient
        def self.endpoint
          '/status/sphygmomanometer.json'
        end

        def self.properties
          {
            :maximal_pressure => {:code =>  '622E', :type =>  Integer},
            :minimal_pressure => {:code =>  '622F', :type =>  Integer},
            :pulse => {:code =>  '6230', :type =>  Integer}
          }
        end
      end

      class Pedometer < BaseApiClient
        def self.endpoint
          '/status/pedometer.json'
        end

        def self.properties
          {
            :steps => {:code =>  '6331', :type =>  Integer},
            :exercise => {:code => '6335', :type => Integer},
            :calories => {:code => '6336', :type => Integer}
          }
        end
      end

      class Smug < BaseApiClient
        def self.endpoint
          '/status/smug.json'
        end

        def self.properties
          {
            :urinary_sugar => {:code => '6240', :type => Integer}
          }
        end
      end
    end
  end
end
