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
        @connected_edges = {}
      end

      def remove_tokens!
        @tokens.map! { nil }
      end

      def blocks?(corporation)
        return false unless corporation
        return false if tokened_by?(corporation)
        return false if @tokens.include?(nil)

        true
      end

      def tokened_by?(corporation)
        @tokens.any? { |t| t&.corporation == corporation }
      end

      def reserved_by?(corporation)
        @reservations.any? { |r| r == corporation.name }
      end

      def add_reservation!(corporation_sym)
        @reservations << corporation_sym
      end

      def city?
        true
      end

      def tokenable?(corporation)
        return false unless get_slot(corporation)
        return false unless (token = corporation.next_token)
        return false unless token.price <= corporation.cash
        return false if tokened_by?(corporation)

        true
      end

      def get_slot(corporation)
        @reservations.index(corporation.name) || @tokens.find_index.with_index do |t, i|
          t.nil? && @reservations[i].nil?
        end
      end

      def place_token(corporation)
        raise GameError, "Cannot lay token on #{id}" unless tokenable?(corporation)

        token = corporation.next_token
        token.use!
        exchange_token(token)
      end

      def exchange_token(token)
        @tokens[get_slot(token.corporation)] = token
      end

      # returns Array[Integer] of all edges that this city are connected to
      def connected_edges
        @connected_edges[tile.rotation] ||= tile.paths.select { |p| p.city == self }.flat_map(&:edges).map(&:num).sort
      end
    end
  end
end
