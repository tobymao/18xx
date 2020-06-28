# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class CompanyPendingPar < Base
      ACTIONS = %w[par].freeze

      def description
        'Choose Corporation Par Value'
      end

      def actions(entity)
        return [] unless current_entity == entity

        ACTIONS
      end

      def active_entities
        [@round.company_pending_par&.owner].compact
      end

      def process_par(action)
        share_price = action.share_price
        corporation = action.corporation
        @game.stock_market.set_par(corporation, share_price)
        @game.share_pool.buy_shares(action.entity, corporation.shares.first, exchange: :free)
        @round.company_pending_par = nil
      end
    end
  end
end
