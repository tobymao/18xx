# frozen_string_literal: true

require_relative '../game_error'
require_relative 'revenue_center'

module Engine
  module Part
    class City < RevenueCenter
      attr_accessor :reservations
      attr_reader :slots, :tokens

      def initialize(revenue, slots = 1, groups = nil, hide = false)
        super(revenue, groups, hide)
        @slots = slots.to_i
        @tokens = Array.new(@slots)
        @reservations = []
      end

      def remove_tokens!
        @tokens.map! { nil }
      end

      def blocks?(corporation)
        return false unless corporation
        return false if tokened_by?(corporation)
        return false if @tokens.include?(nil)
        return false if @tokens.any? { |t| t&.type == :neutral }

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

      def tokenable?(corporation, free: false, tokens: corporation.next_tokens_by_type)
        return false unless tokens

        tokens.any? do |t|
          next false unless get_slot(t.corporation)
          next false if !free && t.price > corporation.cash
          next false if @tile.cities.any? { |c| c.tokened_by?(t.corporation) }

          true
        end
      end

      def get_slot(corporation)
        @reservations.index(corporation.name) || @tokens.find_index.with_index do |t, i|
          t.nil? && @reservations[i].nil?
        end
      end

      def place_token(corporation, token, free: false)
        unless tokenable?(corporation, free: free, tokens: [token])
          raise GameError, "#{corporation.name} cannot lay token on #{id}"
        end

        token.use!
        exchange_token(token)
      end

      def exchange_token(token)
        @tokens[get_slot(token.corporation)] = token
      end
    end
  end
end
