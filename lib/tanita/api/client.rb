# frozen_string_literal: true

require 'tanita/api/client/base'
require 'tanita/api/client/helpers'
require 'tanita/api/client/version'

module Tanita
  module Api
    module Client
      class Auth
        include HttpHelper

        def initialize(client_id:, client_secret:, redirect_uri:, scopes: [Scope::INNERSCAN])
          @client_id = client_id
          @client_secret = client_secret
          @redirect_uri = redirect_uri
          @scopes = scopes
        end

        def auth_uri
          params = {
            :client_id => @client_id,
            :redirect_uri => @redirect_uri,
            :scope => @scopes.join(','),
            :response_type => 'code'
          }
          generate_uri('/oauth/auth', params)
        end

        def exchange_token(auth_code:)
          params = {
            :client_id => @client_id,
            :client_secret => @client_secret,
            :redirect_uri => DEFAULT_REDIRECT_URI,
            :code => auth_code,
            :grant_type => 'authorization_code'
          }
          res = request('/oauth/token', params)
          token = parse_json(res.body)

          raise Error.new("#{self.class}.#{__method__}: #{token[:error]}") if token.key? :error

          token
        end
      end

      class Innerscan < BaseApiClient
        def endpoint
          '/status/innerscan.json'
        end

        def measurement_tags
          {
            :weight => '6021',
            :body_fat => '6022',
            :muscle_mass => '6023',
            :physique_rating => '6024',
            :visceral_fat_rating2 => '6025',
            :visceral_fat_rating1 => '6026',
            :basal_metabolic_rate => '6027',
            :metabolic_age => '6028',
            :bone_mass => '6029'
          }
        end
      end

      class Sphygmomanometer < BaseApiClient
        def endpoint
          '/status/sphygmomanometer.json'
        end

        def measurement_tags
          {
            :maximal_pressure => '622E',
            :minimal_pressure => '622F',
            :pulse => '6230'
          }
        end
      end

      class Pedometer < BaseApiClient
        def endpoint
          '/status/pedometer.json'
        end

        def measurement_tags
          {
            :steps => '6331',
            :exercise => '6335',
            :calories => '6336'
          }
        end
      end

      class Smug < BaseApiClient
        def endpoint
          '/status/smug.json'
        end

        def measurement_tags
          {
            :urinary_sugar => '6240'
          }
        end
      end
    end
  end
end
