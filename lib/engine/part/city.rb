# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class City < Base
      attr_reader :name, :revenue, :slots, :tokens

      def initialize(revenue, slots = 1, name = nil)
        @revenue = revenue.to_i
        @slots = slots.to_i
        @name = name
        @tokens = Array.new(@slots)
      end

      def ==(other)
        other.city? &&
          @revenue == other.revenue &&
          @slots == other.slots &&
          @name == other.name &&
          @tokens == other.tokens
      end

      def city?
        true
      end

      def place_token(corporation, slot)
        # a token is already in this slot
        return unless @tokens[slot].nil?

        # corporation already placed a token in this city
        return if @tokens.compact.map(&:corporation).include?(corporation)

        # corporation already placed all their tokens
        return if corporation.tokens.select(&:unplaced?).empty?

        # place token on this city
        token = corporation.tokens.find(&:unplaced?)
        token.place
        @tokens[slot] = token
      end
    end
  end
end
