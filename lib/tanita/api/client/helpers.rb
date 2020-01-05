# frozen_string_literal: true

require 'json'
require 'net/https'

module Tanita
  module Api
    module Client
      module HttpHelper
        BASE_URL = 'https://www.healthplanet.jp'
        DEFAULT_REDIRECT_URI = "#{BASE_URL}/success.html"

        def generate_uri(path, params)
          uri = URI.parse("#{BASE_URL}#{path}?#{URI.encode_www_form(params)}")
          uri.to_s
        end

        def request(path, params)
          uri = URI.parse("#{BASE_URL}#{path}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          req = Net::HTTP::Post.new(uri.path)
          req.set_form_data(params)
          http.request(req)
        end

        def parse_json(str)
          JSON.parse(str, :symbolize_names => true)
        rescue JSON::ParserError => e
          raise Error.new("JSON::ParseError: '#{e}'\nstr:#{str}")
        end
      end
    end
  end
end
