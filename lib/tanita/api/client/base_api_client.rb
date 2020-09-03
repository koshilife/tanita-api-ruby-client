# frozen_string_literal: true

require 'time'
require 'tanita/api/client/helpers'

module Tanita
  module Api
    module Client
      DATE_TYPE_REGISTERD_AT = 0
      DATE_TYPE_MEASURED_AT = 1

      class BaseApiClient
        include HttpHelper

        def self.endpoint
          raise NotImplementedError
        end

        def self.properties
          raise NotImplementedError
        end

        def initialize(access_token: nil, date_type: DATE_TYPE_MEASURED_AT)
          config = Tanita::Api::Client.configuration
          @access_token = access_token || config.access_token
          raise Error.new("param:'access_token' is required.'") if @access_token.nil?

          @date_type = date_type
          unless [DATE_TYPE_REGISTERD_AT, DATE_TYPE_MEASURED_AT].include? date_type
            raise Error.new("param:'date_type' is invalid.'")
          end

          ClassBuilder.load
        end

        def status(
          from: nil,
          to: nil
        )
          tags = self.class.properties.values.map { |i| i[:code] }.join(',')
          params = {
            access_token: @access_token,
            date: @date_type,
            tag: tags
          }
          params[:from] = time_format(from) unless from.nil?
          params[:to] = time_format(to) unless to.nil?
          res = request(self.class.endpoint, params)
          build_result(res)
        end

        def inspect
          "\#<#{self.class}:#{object_id}>"
        end

      private

        def build_result(res)
          result = parse_json(res.body)
          Result.new(
            birth_date: Date.parse(result[:birth_date]),
            height: result[:height].to_f,
            sex: result[:sex],
            items: build_result_items(raw_items: result[:data])
          )
        end

        def build_result_items(raw_items:)
          item_dic = {}
          raw_items.each do |item|
            date = item[:date]
            model = item[:model]
            key = "#{date}_#{model}"
            property = find_property_by_code(code: item[:tag])
            value = cast(value: item[:keydata], type: property[:type])
            item_dic[key] ||= {}
            item_dic[key][date_key] = Time.parse("#{date} +09:00").to_i unless item_dic[key].key? :date
            item_dic[key][:model] = model unless item_dic[key].key? :model
            item_dic[key][property[:name]] = value
          end
          items = item_dic.values.sort_by { |dic| dic[date_key] } # sort by date in ascending order
          items.map { |_item_dic| eval "#{self.class}Item.new _item_dic" }
        end

        def cast(value:, type:)
          return value if value.nil?
          return value.to_i if type == Integer
          return value.to_f if type == Float

          value
        end

        def find_property_by_code(code:)
          return @property_code_dic[code] unless @property_code_dic.nil?

          @property_code_dic = {}
          self.class.properties.each do |m_name, m_info|
            @property_code_dic[m_info[:code]] = {name: m_name, type: m_info[:type]}
          end
          @property_code_dic[code]
        end

        def date_key
          case @date_type
          when DATE_TYPE_REGISTERD_AT
            :registered_at
          when DATE_TYPE_MEASURED_AT
            :measured_at
          end
        end
      end
    end
  end
end
