# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'
require 'view/game/sell_shares'

module View
  module Game
    class BuySellShares < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        step = @game.round.active_step
        current_entity = step.current_entity

        ipo_share = @corporation.shares[0]

        children = []

        if step.current_actions.include?('buy_shares')
          if step.can_buy?(current_entity, ipo_share)
            children << h(
              :button,
              { on: { click: -> { buy_share(current_entity, ipo_share) } } },
              "Buy #{@game.class::IPO_NAME} Share",
            )
          end

          # Put up one buy button for each buyable percentage share type in market.
          # In case there are more than one type of percentages in market (e.g. 18MEX), show percentage type on button.
          pool_shares = @game.share_pool.shares_by_corporation[@corporation].group_by(&:percent).values.collect(&:first)
          pool_shares
            .select { |share| step.can_buy?(current_entity, share) }
            .each do |share|
              text = pool_shares.size > 1 ? "Buy #{share.percent}% Market Share" : 'Buy Market Share'
              children << h(:button, { on: { click: -> { buy_share(current_entity, share) } } }, text)
            end
        end

        if step.current_actions.include?('short') && step.can_short?(current_entity, @corporation)
          short = lambda do
            process_action(Engine::Action::Short.new(current_entity, corporation: @corporation))
          end

          children << h(
            :button,
            { on: { click: short } },
            'Short Share',
          )
        end

        # Allow privates to be exchanged for shares
        @game.companies.each do |company|
          company.abilities(:exchange) do |ability|
            next unless ability.corporation == @corporation.name
            next unless company.owner == current_entity

            prefix = "Exchange #{company.sym} for "

            if ability.from.include?(:ipo) && step.can_gain?(company.owner, ipo_share, exchange: true)
              children << h(:button, { on: { click: -> { buy_share(company, ipo_share) } } },
                            "#{prefix} an #{@game.class::IPO_NAME} share")
            end

            if ability.from.include?(:market) && step.can_gain?(company.owner, pool_share, exchange: true)
              children << h(:button, { on: { click: -> { buy_share(company, pool_share) } } },
                            "#{prefix} a Market share")
            end
          end
        end

        children << h(SellShares, player: current_entity, corporation: @corporation)

        h(:div, children)
      end

      def buy_share(entity, share)
        process_action(Engine::Action::BuyShares.new(entity, shares: share))
      end
    end
  end
end
