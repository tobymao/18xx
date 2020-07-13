# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Bankrupt < Base
      ACTIONS = %w[bankrupt].freeze

      def actions(entity)
        return [] if entity != current_entity

        ACTIONS
      end

      def description
        'Bankrupt'
      end

      def blocks?
        false
      end

      def process_bankrupt(action)
        player = action.entity

        @log << "#{player.name} goes bankrupt and sells remaining shares"

        player.shares_by_corporation.each do |corporation, _|
          next unless corporation.share_price # if a corporation has not parred
          next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

          @game.sell_shares_and_change_price(bundle)
          @round.recalculate_order
        end

        player.spend(player.cash, @game.bank)

        @game.bankruptcies += 1
      end
    end
  end
end
