# frozen_string_literal: true

module Tanita
  module Api
    module Client
      class BaseEntity
        def initialize(property_values = {})
          @cached_property_values = {}
          @cached_property_values.merge!(property_values)
        end

        def to_h
          ret = {}
          self.class.properties.each do |property|
            ret[property.to_sym] = eval property.to_s
          end
          ret
        end

        def inspect
          "\#<#{self.class}:#{object_id} properties=#{self.class.properties.join(',')}>"
        end
      end
    end
  end
end
