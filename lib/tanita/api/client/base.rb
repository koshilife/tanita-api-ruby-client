# frozen_string_literal: true

require 'time'
require 'tanita/api/client/helpers'

module Tanita
  module Api
    module Client
      module Scope
        INNERSCAN = 'innerscan'
        SPHYGMOMANOMETER = 'sphygmomanometer'
        PEDOMETER = 'pedometer'
        SMUG = 'smug'
        def self.all
          constants.map { |name| const_get(name) }
        end
      end

      class Error < StandardError
      end

      DATE_TYPE_REGISTERD_AT = 0
      DATE_TYPE_MEASURED_AT = 1

      class BaseApiClient
        include HttpHelper

        def initialize(access_token: nil, date_type: DATE_TYPE_MEASURED_AT)
          config = Tanita::Api::Client.configuration
          @access_token = access_token || config.access_token
          raise Error.new("param:'access_token' is required.'") if @access_token.nil?

          @date_type = date_type
          raise Error.new("param:'date_type' is invalid.'") unless [DATE_TYPE_REGISTERD_AT, DATE_TYPE_MEASURED_AT].include? date_type
        end

        def status(
          from: nil,
          to: nil
        )
          tags = measurement_tags.values.map { |i| i[:code] }.join(',')
          params = {
            :access_token => @access_token,
            :date => @date_type,
            :tag => tags
          }
          params[:from] = time_format(from) unless from.nil?
          params[:to] = time_format(to) unless to.nil?
          res = request(endpoint, params)
          Result.new(:client => self, :response => res)
        end

        def endpoint
          raise NotImplementedError
        end

        def measurement_tags
          raise NotImplementedError
        end

        def find_measurement_tag(code:)
          return @inverted_measurement[code] unless @inverted_measurement.nil?

          @inverted_measurement = {}
          measurement_tags.each do |m_name, m_info|
            @inverted_measurement[m_info[:code]] = {:name => m_name, :type => m_info[:type]}
          end
          @inverted_measurement[code]
        end

        def date_key
          case @date_type
          when DATE_TYPE_REGISTERD_AT
            :registered_at
          when DATE_TYPE_MEASURED_AT
            :measured_at
          end
        end

      private

        def time_format(time)
          time.strftime('%Y%m%d%H%M%S')
        end
      end

      class Result
        include HttpHelper

        # [Date]
        attr_reader :birth_date

        # [Float] (centimeter)
        attr_reader :height

        # [String] 'male' or 'female'
        attr_reader :sex

        # [Array<Hash>]
        attr_reader :items

        def initialize(client:, response:)
          @client = client
          result = parse_json(response.body)
          @birth_date = Date.parse(result[:birth_date])
          @height = result[:height].to_f
          @sex = result[:sex]
          @items = build_items(result[:data])
        end

      private

        def build_items(raw_items)
          item_dic = {}
          raw_items.each do |item|
            date = item[:date]
            model = item[:model]
            key = "#{date}_#{model}"
            measurement = @client.find_measurement_tag(:code => item[:tag])
            value = cast(:value => item[:keydata], :type => measurement[:type])
            item_dic[key] ||= {}
            item_dic[key][@client.date_key] = Time.parse("#{date} +09:00").to_i unless item_dic[key].key? :date
            item_dic[key][:model] = model unless item_dic[key].key? :model
            item_dic[key][measurement[:name]] = value
          end
          # sort by date in ascending order
          item_dic.values.sort_by { |dic| dic[@client.date_key] }
        end

        def cast(value:, type:)
          return value if value.nil?
          return value.to_i if type == Integer
          return value.to_f if type == Float

          value
        end
      end
    end
  end
end
