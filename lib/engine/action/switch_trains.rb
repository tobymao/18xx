# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class SwitchTrains < Base
      attr_reader :slots

      def initialize(entity, slots: nil)
        super(entity)
        @slots = slots
      end

      def self.h_to_args(h, _game)
        {
          slots: h['slots']&.map { |m| m.to_i },
        }
      end

      def args_to_h
        {
          'slots' => @slots,
        }
      end
    end
  end
end
