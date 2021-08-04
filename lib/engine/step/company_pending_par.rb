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

      def active?
        companies_pending_par.any?
      end

      def active_entities
        [@round.companies_pending_par.first&.owner].compact
      end

      def process_par(action)
        share_price = action.share_price
        corporation = action.corporation
        @game.stock_market.set_par(corporation, share_price)
        @game.share_pool.buy_shares(action.entity, corporation.shares.first, exchange: :free)
        @game.after_par(corporation)
        @round.companies_pending_par.shift
      end

      def companies_pending_par
        @round.companies_pending_par
      end

      def get_par_prices(_entity, _corp)
        @game
          .stock_market
          .par_prices
      end
    end
  end
end
