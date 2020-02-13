# frozen_string_literal: true

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

    end
  end
end
