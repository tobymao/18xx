# frozen_string_literal: true

require_relative '../game_error'
require_relative 'base'
require_relative 'revenue_center'

module Engine
  module Part
    class City < Base
      include Part::RevenueCenter

      attr_accessor :reservations
      attr_reader :slots, :tokens, :revenue

      def initialize(revenue, slots = 1)
        @revenue = parse_revenue(revenue)
        @slots = slots.to_i
        @tokens = Array.new(@slots)
        @reservations = []
      end

      def ==(other)
        other.city? &&
          @revenue == other.revenue &&
          @slots == other.slots &&
          @tokens == other.tokens &&
          @reservations == other.reservations
      end

      def hex
        @tile&.hex
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

      def tokenable?(corporation)
        return false unless (slot = get_slot(corporation))
        return false if corporation.tokens.empty?
        return false if @tokens[slot]
        return false if @tokens.compact.map(&:corporation).include?(corporation)

        true
      end

      def get_slot(corporation)
        @reservations.index(corporation.sym) || @tokens.find_index.with_index do |t, i|
          t.nil? && @reservations[i].nil?
        end
      end

      def place_token(corporation)
        raise GameError, 'Cannot lay token' unless tokenable?(corporation)

        exchange_token(corporation.tokens.pop)
      end

      def exchange_token(token)
        @tokens[get_slot(token.corporation)] = token
      end
    end
  end
end
