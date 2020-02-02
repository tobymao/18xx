# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class City < Base
      attr_reader :name, :revenue, :slots, :tokens, :reservations

      def initialize(revenue, slots = 1, name = nil, reservations = [])
        @revenue = revenue.to_i
        @slots = slots.to_i
        @name = name
        @tokens = Array.new(@slots)
        @reservations = reservations || []
      end

      def ==(other)
        other.city? &&
          @revenue == other.revenue &&
          @slots == other.slots &&
          @name == other.name &&
          @tokens == other.tokens &&
          @reservations == other.reservations
      end

      def city?
        true
      end

      def place_token(corporation, slot)
        # the slot is reserved for a different corporation
        reservation = @reservations[slot]
        unless reservation.nil?
          return unless corporation.sym == reservation
        end

        # a token is already in this slot
        return unless @tokens[slot].nil?

        # corporation has a reservation for a different spot in the city
        return unless [nil, slot].include?(@reservations.index(corporation.sym))

        # corporation already placed a token in this city
        return if @tokens.compact.map(&:corporation).include?(corporation)

        # corporation already placed all their tokens
        return if corporation.tokens.select(&:unplaced?).empty?

        # place token on this city
        token = corporation.tokens.find(&:unplaced?)
        token.place!
        @tokens[slot] = token
      end
    end
  end
end
