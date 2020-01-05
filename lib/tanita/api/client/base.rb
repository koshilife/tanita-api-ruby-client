# frozen_string_literal: true

require 'tanita/api/client/helpers'

module Tanita
  module Api
    module Client
      module Scope
        INNERSCAN = 'innerscan'
        SPHYGMOMANOMETER = 'sphygmomanometer'
        PEDOMETER = 'pedometer'
        SMUG = 'smug'
      end

      class Error < StandardError
      end

      class BaseApiClient
        include HttpHelper

        DATE_REGISTERD_AT = 0
        DATE_MEASURED_AT = 1

        def initialize(access_token:)
          @access_token = access_token
        end

        def endpoint
          raise NotImplementedError
        end

        def measurement_tags
          raise NotImplementedError
        end

        def status(
          date_type: DATE_MEASURED_AT,
          from: nil,
          to: nil
        )
          tags = measurement_tags.values.join(',')
          params = {
            :access_token => @access_token,
            :date => date_type,
            :tag => tags
          }
          params[:from] = time_format(from) unless from.nil?
          params[:to] = time_format(to) unless to.nil?

          res = request(endpoint, params)
          Result.new(:response => res, :client => self)
        end

      private

        def time_format(time)
          time.strftime('%Y%m%d%H%M%S')
        end
      end

      class Result
        include HttpHelper
        attr_reader :birth_date
        attr_reader :height
        attr_reader :sex
        attr_reader :data

        def initialize(response:, client:)
          result = parse_json(response.body)
          @birth_date = result[:birth_date]
          @height = result[:height]
          @sex = result[:sex]

          mapper = client.measurement_tags.invert
          set_data(result[:data], mapper)
        end

      private

        def set_data(items, mapper)
          data_dic = {}
          items.each do |item|
            date = item[:date]
            model = item[:model]
            key = "#{date}_#{model}"
            measurement = mapper[item[:tag]]
            value = item[:keydata]

            data_dic[key] ||= {}
            data_dic[key][:date] = date unless data_dic[key].key? :date
            data_dic[key][:model] = model unless data_dic[key].key? :model
            data_dic[key][measurement] = value
          end
          # sort by date in ascending order
          @data = data_dic.values { |dic| -dic[:date] }
        end
      end
    end
  end
end
