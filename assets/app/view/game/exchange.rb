# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Exchange < Snabberb::Component
      include Actionable

      needs :selected_company, default: nil, store: true

      def render
        return h(:div) unless (ability = @selected_company&.abilities(:exchange))

        corporation = @game.corporation_by_id(ability.corporation)
        share = corporation.shares.find { |s| !s.president }

        return h(:div) unless share
        return h(:div) unless @game.round.can_gain?(share, @selected_company.owner)

        exchange = lambda do
          process_action(Engine::Action::BuyShares.new(@selected_company, shares: share))
          store(:selected_company, nil, skip: true)
        end

        h(:button, { on: { click: exchange } }, "Exchange for a share of #{corporation.name}")
      end
    end
  end
end
