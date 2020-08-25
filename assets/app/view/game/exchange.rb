# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Exchange < Snabberb::Component
      include Actionable

      needs :selected_company, default: nil, store: true

      def render_exchange(share, share_origin)
        step = @game.round.active_step(@selected_company)
        return nil unless share
        return nil if !step.respond_to?(:can_gain?) || !step.can_gain?(@selected_company.owner, share, exchange: true)

        exchange = lambda do
          process_action(Engine::Action::BuyShares.new(@selected_company, shares: share))
          store(:selected_company, nil, skip: true)
        end

        h(:button,
          { on: { click: exchange } },
          "Exchange #{@selected_company.sym} for a #{share_origin} share of #{share.corporation.name}")
      end

      def render
        return h(:span) unless (ability = @selected_company&.abilities(:exchange))

        corporation = @game.corporation_by_id(ability.corporation)
        children = []
        ipo_share = corporation.shares.find { |s| !s.president }
        children << render_exchange(ipo_share, @game.class::IPO_NAME) if ability.from.include?(:ipo)

        pool_share = @game.share_pool.shares_by_corporation[corporation]&.first
        children << render_exchange(pool_share, 'Market') if ability.from.include?(:market)

        h(:span, children.compact)
      end
    end
  end
end
