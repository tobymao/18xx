# frozen_string_literal: true

require_relative 'base'
require_relative 'share_buying'
require_relative '../action/corporate_sell_shares'

module Engine
  module Step
    class CorporateSellShares < Base
      include ShareBuying

      def description
        'Corporate Share Sales'
      end

      def actions(entity)
        return [] unless entity == current_entity

        actions = []
        actions << 'corporate_sell_shares' if can_sell_any?(entity)

        actions << 'pass' if actions.any?

        actions
      end

      def log_pass(entity)
        @log << "#{entity.name} passes selling shares"
      end

      def log_skip(entity)
        @log << "#{entity.name} skips corporate share sales"
      end

      def can_sell_any?(entity)
        entity.corporate_shares.select { |share| can_sell?(entity, share.to_bundle) }.any?
      end

      def can_sell?(entity, bundle)
        return unless bundle

        entity != bundle.corporation && !bought?(entity, bundle.corporation)
      end

      def process_corporate_sell_shares(action)
        sell_shares(action.entity, action.bundle, swap: action.swap)
        pass! unless can_sell_any?(action.entity)
      end

      def sell_shares(entity, shares, swap: nil)
        @game.game_error("Cannot sell shares of #{shares.corporation.name}") if !can_sell?(entity, shares) && !swap

        @game.sell_shares_and_change_price(shares, swap: swap)
      end

      def source_list(entity)
        entity.corporate_shares.map do |share|
          next if bought?(entity, share.corporation)

          share.corporation
        end.compact
      end

      def bought?(entity, corporation)
        @round.corporations_bought[entity].include?(corporation)
      end
    end
  end
end
