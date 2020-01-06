# frozen_string_literal: true

module Tanita
  module Api
    module Client
      class Configuration
        # [String]
        attr_accessor :client_id

        # [String]
        attr_accessor :client_secret

        # [String]
        attr_accessor :redirect_uri

        # [String]
        attr_accessor :access_token

        # [Array<Tanita::Api::Client::Scope>]
        attr_accessor :scopes
      end
    end
  end
end
