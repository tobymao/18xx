# frozen_string_literal: true

require_relative '../game_error'
require_relative 'revenue_center'

module Engine
  module Part
    class City < RevenueCenter
      attr_accessor :reservations
      attr_reader :tokens

      def initialize(revenue, **opts)
        super
        @slots = (opts[:slots] || 1).to_i
        @tokens = Array.new(@slots)
        @reservations = []
      end

      def slots
        @tokens.size
      end

      def normal_slots
        @slots
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

      def find_reservation(corporation)
        @reservations.find_index { |r| r && [r, r.owner].include?(corporation) }
      end

      def reserved_by?(corporation)
        !!find_reservation(corporation)
      end

      def add_reservation!(entity, slot = nil)
        if slot
          @reservations.insert(slot, entity)
        else
          @reservations << entity
        end
      end

      def remove_reservation!(entity)
        @reservations.delete(entity)
      end

      def city?
        true
      end

      def tokenable?(corporation, free: false, tokens: corporation.tokens_by_type, cheater: false)
        tokens = Array(tokens)
        return false if tokens.empty?

        tokens.any? do |t|
          next false unless get_slot(t.corporation, cheater: cheater)
          next false if !free && t.price > corporation.cash
          next false if @tile.cities.any? { |c| c.tokened_by?(t.corporation) }
          next true if reserved_by?(corporation)
          next false if @tile.token_blocked_by_reservation?(corporation)

          true
        end
      end

      def available_slots
        @tokens.each_with_index.count { |t, i| t.nil? && @reservations[i].nil? }
      end

      def get_slot(corporation, cheater: false)
        reservation = find_reservation(corporation)
        open_slot = @tokens.find_index.with_index do |t, i|
          t.nil? && @reservations[i].nil?
        end
        return [open_slot || @slots, cheater].max if cheater

        reservation || open_slot
      end

      def place_token(corporation, token, free: false, check_tokenable: true, cheater: false)
        if check_tokenable && !tokenable?(corporation, free: free, tokens: token, cheater: cheater)
          raise GameError, "#{corporation.name} cannot lay token on #{id}"
        end

        exchange_token(token, cheater: cheater)
        tile.reservations.delete(corporation)
      end

      def exchange_token(token, cheater: false)
        token.place(self)
        @tokens[get_slot(token.corporation, cheater: cheater)] = token
      end
    end
  end
end
