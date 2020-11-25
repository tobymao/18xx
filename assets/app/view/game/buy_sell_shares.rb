# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'
require 'view/game/sell_shares'
require 'view/game/button/buy_share'

module View
  module Game
    class BuySellShares < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        @step = @game.round.active_step
        @current_entity = @step.current_entity

        @ipo_shares = @corporation.shares.group_by(&:percent).values
          .map(&:first).sort { |a, b| b.percent <=> a.percent }

        @pool_shares = @game.share_pool.shares_by_corporation[@corporation].group_by(&:percent).values
          .map(&:first).sort { |a, b| b.percent <=> a.percent }

        children = []

        children.concat(render_buy_shares)
        children.concat(render_short)
        children.concat(render_exchanges)

        children << h(SellShares, player: @current_entity, corporation: @corporation)

        h(:div, children.compact)
      end

      def render_buy_shares
        return [] unless @step.current_actions.include?('buy_shares')

        children = []

        children.concat(render_ipo_shares)
        children.concat(render_market_shares)
        children.concat(render_price_protection)
        children.concat(render_reduced_price_shares(@ipo_shares, source: @game.class::IPO_NAME))
        children.concat(render_reduced_price_shares(@pool_shares))

        children.compact
      end

      # Put up one buy button for each buyable percentage share type in market.
      # In case there are more than one type of percentages in market or if shares are not the
      # standard percent (e.g. 5% in 18MEX), show percentage type on button.
      # Do skip president's share in case there are other shares available.
      def render_market_shares
        @pool_shares.map do |share|
          next unless @step.can_buy?(@current_entity, share)
          next if share.president && @pool_shares.size > 1

          h(Button::BuyShare,
            share: share,
            entity: @current_entity,
            percentages_available: @pool_shares.size)
        end.compact
      end

      def render_ipo_shares
        @ipo_shares.map do |share|
          next unless @step.can_buy?(@current_entity, share)

          h(Button::BuyShare,
            share: share,
            entity: @current_entity,
            percentages_available: @ipo_shares.size,
            source: @game.class::IPO_NAME)
        end.compact
      end

      def render_price_protection
        return [] unless @step.respond_to?(:price_protection)

        price_protection = @step.price_protection

        return [] unless price_protection

        protect = lambda do
          process_action(Engine::Action::BuyShares.new(@current_entity, shares: price_protection.shares))
        end

        [h(:button, { on: { click: -> { protect } } }, 'Protect Shares')]
      end

      def render_reduced_price_shares(shares, source: 'Market')
        shares.map do |share|
          next unless (swap_share = @step.swap_buy(@current_entity, @corporation, share))

          h(Button::BuyShare,
            share: share,
            swap_share: swap_share,
            entity: @current_entity,
            percentages_available: shares.size,
            source: source)
        end
      end

      def render_short
        return [] unless @step.current_actions.include?('short')
        return [] unless @step.can_short?(@current_entity, @corporation)

        short = lambda do
          process_action(Engine::Action::Short.new(@current_entity, corporation: @corporation))
        end

        [h(:button, { on: { click: short } }, 'Short Share')]
      end

      # Allow privates to be exchanged for shares
      def render_exchanges
        children = []

        @game.companies.each do |company|
          company.abilities(:exchange) do |ability|
            next if ability.corporation != @corporation.name && ability.corporation != 'any'
            next unless company.owner == @current_entity

            if ability.from.include?(:ipo)
              children.concat(render_share_exchange(@ipo_shares, company, source: @game.class::IPO_NAME))
            end

            children.concat(render_share_exchange(@pool_shares, company)) if ability.from.include?(:market)
          end
        end

        children
      end

      # Put up one exchange button for each exchangable percentage share type in market.
      def render_share_exchange(shares, company, source: 'Market')
        shares.map do |share|
          next unless @step.can_gain?(company.owner, share, exchange: true)

          h(Button::BuyShare,
            share: share,
            entity: company,
            percentages_available: shares.size,
            prefix: "Exchange #{company.sym} for ",
            source: source)
        end.compact
      end
    end
  end
end
