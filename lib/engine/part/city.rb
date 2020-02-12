# frozen_string_literal: true

require 'engine/part/base'
require 'engine/part/revenue_center'

module Engine
  module Part
    class City < Base
      include Part::RevenueCenter

      attr_accessor :reservations
      attr_reader :name, :slots, :tokens

      def initialize(revenue, slots = 1, name = nil, reservations = [])
        @revenue = parse_revenue(revenue)
        @slots = slots.to_i
        @name = name
        @tokens = Array.new(@slots)
        @reservations = reservations&.map(&:to_sym) || []
      end

      def ==(other)
        other.city? &&
          @revenue == other.revenue &&
          @slots == other.slots &&
          @name == other.name &&
          @tokens == other.tokens &&
          @reservations == other.reservations
      end

      def <=(other)
        other.city? && (@name == other.name)
      end

      def city?
        true
      end

      def place_token(corporation)
        # the slot is reserved for a different corporation
        slot = @reservations.index(corporation.sym) || @tokens.find_index.with_index do |t, i|
          t.nil? && @reservations[i].nil?
        end

        # a token is already in this slot
        raise unless @tokens[slot].nil?

        # corporation has a reservation for a different spot in the city
        raise unless [nil, slot].include?(@reservations.index(corporation.sym))

        # corporation already placed a token in this city
        raise if @tokens.compact.map(&:corporation).include?(corporation)

        # corporation already placed all their tokens
        raise if corporation.tokens.select(&:unplaced?).empty?

        # place token on this city
        token = corporation.tokens.find(&:unplaced?)
        token.place!
        @tokens[slot] = token
      end
    end
  end
end
