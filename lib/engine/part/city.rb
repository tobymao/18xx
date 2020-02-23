# frozen_string_literal: true

require 'engine/part/base'
require 'engine/part/revenue_center'

module Engine
  module Part
    class City < Base
      include Part::RevenueCenter

      attr_accessor :id, :reservations
      attr_reader :local_id, :slots, :tokens

      def initialize(revenue, slots = 1, local_id = 0)
        @revenue = parse_revenue(revenue)
        @slots = slots.to_i
        @local_id = local_id.to_i
        @tokens = Array.new(@slots)
        @reservations = []
      end

      def ==(other)
        other.city? &&
          @revenue == other.revenue &&
          @slots == other.slots &&
          @local_id == other.local_id &&
          @tokens == other.tokens &&
          @reservations == other.reservations
      end

      def <=(other)
        other.city?
      end

      def tokened_by?(corporation)
        @tokens.any? { |t| t&.corporation == corporation }
      end

      def reserved_by?(corporation)
        @reservations.any? { |r| r == corporation.sym }
      end

      def add_reservation!(corporation_sym)
        @reservations << corporation_sym
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
