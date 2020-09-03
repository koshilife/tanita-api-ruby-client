# frozen_string_literal: true

module Tanita
  module Api
    module Client
      class Configuration
        # @return [String]
        attr_accessor :client_id
        # @return [String]
        attr_accessor :client_secret
        # @return [String]
        attr_accessor :redirect_uri
        # @return [String]
        attr_accessor :access_token
        # @return [Array<Tanita::Api::Client::Scope>]
        attr_accessor :scopes
      end
    end
  end
end
