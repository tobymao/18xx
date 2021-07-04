# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyPower < Base
      attr_reader :power

      def initialize(entity, power:)
        super(entity)
        @power = power
      end

      def self.h_to_args(h, _game)
        {
          power: h['power'],
        }
      end

      def args_to_h
        {
          'power' => @power,
        }
      end
    end
  end
end
