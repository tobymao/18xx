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

        @ipo_shares = @corporation.ipo_shares.select(&:buyable).group_by(&:percent).values
          .map(&:first).sort_by(&:percent).reverse

        @treasury_shares = if @corporation.ipo_is_treasury?
                             []
                           else
                             @corporation.treasury_shares.select(&:buyable).group_by(&:percent).values
                               .map(&:first).sort_by(&:percent).reverse
                           end

        @pool_shares = if @step.respond_to?(:pool_shares)
                         @step.pool_shares(@corporation)
                       else
                         @game.share_pool.shares_by_corporation[@corporation].group_by(&:percent).values
                           .map(&:first).sort_by(&:percent).reverse
                       end

        @reserved_shares = @corporation.reserved_shares

        children = []

        if @corporation.ipoed
          children.concat(render_buy_shares)
          children.concat(render_merge)
          children.concat(render_convert)
          children.concat(render_short)
        end
        children.concat(render_exchanges)

        children << h(SellShares, player: @current_entity, corporation: @corporation) if @corporation.ipoed
        children << h(Split, corporation: @corporation) if @step.actions(@current_entity).include?('split') &&
                                                           @game.respond_to?(:can_split?) &&
                                                           @game.can_split?(@corporation, @current_entity)

        children.compact!
        return h(:div, children) unless children.empty?

        nil
      end

      def render_buy_shares
        return [] unless @step.current_actions.include?('buy_shares')

        children = []

        children.concat(render_ipo_shares)
        children.concat(render_treasury_shares)
        children.concat(render_market_shares)
        children.concat(render_corporate_shares)
        children.concat(render_other_player_shares)
        children.concat(render_shares_for_others)
        children.concat(render_price_protection)
        children.concat(render_reduced_price_shares(@ipo_shares, source: @game.ipo_name(@corporation)))
        children.concat(render_reduced_price_shares(@pool_shares))

        children
      end

      # Put up one buy button for each buyable percentage share type in market.
      # In case there are more than one type of percentages in market or if shares are not the
      # standard percent (e.g. 5% in 18MEX), show percentage type on button.
      # Do skip president's share in case there are other shares available.
      def render_market_shares
        @pool_shares.map do |share|
          next unless @step.can_buy?(@current_entity, share.to_bundle)
          if share.to_bundle.presidents_share && @pool_shares.size > 1 && !@game.can_buy_presidents_share_directly_from_market?
            next
          end

          h(Button::BuyShare,
            share: share,
            entity: @current_entity,
            percentages_available: @pool_shares.group_by(&:percent).size)
        end
      end

      def render_ipo_shares
        @ipo_shares.map do |share|
          next unless @step.can_buy?(@current_entity, share.to_bundle)

          h(Button::BuyShare,
            share: share,
            entity: @current_entity,
            percentages_available: @ipo_shares.group_by(&:percent).size,
            source: @game.ipo_name(share.corporation))
        end
      end

      def render_treasury_shares
        @treasury_shares.map do |share|
          next unless @step.can_buy?(@current_entity, share.to_bundle)

          h(Button::BuyShare,
            share: share,
            entity: @current_entity,
            percentages_available: @treasury_shares.group_by(&:percent).size,
            source: 'Treasury')
        end
      end

      def render_corporate_shares
        @corporation.corporate_shares.group_by(&:corporation).values.flat_map do |corp_shares|
          corp_shares.group_by(&:percent).values.map(&:first).sort_by(&:percent).reverse.map do |share|
            next unless @step.can_buy?(@current_entity, share.to_bundle)

            button_prefix = 'Buy'
            button_prefix = @step.corporate_buy_text(share) if @step.respond_to?(:corporate_buy_text)

            h(Button::BuyShare,
              share: share,
              entity: @current_entity,
              percentages_available: @ipo_shares.group_by(&:percent).size,
              source: share.corporation.name,
              prefix: button_prefix)
          end
        end
      end

      def render_other_player_shares
        @corporation.player_share_holders.keys.reject { |sh| sh == @current_entity }.flat_map do |sh|
          shares = sh.shares_of(@corporation).select(&:buyable).group_by(&:percent).values.map(&:first)
          shares.sort_by(&:percent).reverse.map do |share|
            next unless @step.can_buy?(@current_entity, share.to_bundle)

            h(Button::BuyShare,
              share: share,
              entity: @current_entity,
              percentages_available: shares.group_by(&:percent).size,
              source: sh.name)
          end
        end
      end

      def render_shares_for_others
        return [] unless @step.respond_to?(:can_buy_for)

        targets = @step.can_buy_for(@current_entity)

        targets.flat_map do |target|
          ipo_shares = @ipo_shares.map do |share|
            next unless @step.can_buy?(target, share.to_bundle, borrow_from: @current_entity)

            h(Button::BuyShare,
              share: share,
              entity: @current_entity,
              purchase_for: target,
              borrow_from: @current_entity,
              percentages_available: @ipo_shares.group_by(&:percent).size,
              source: @game.ipo_name(share.corporation))
          end

          treasury_shares = @treasury_shares.map do |share|
            next unless @step.can_buy?(target, share.to_bundle, borrow_from: @current_entity)

            h(Button::BuyShare,
              share: share,
              entity: @current_entity,
              purchase_for: target,
              borrow_from: @current_entity,
              percentages_available: @treasury_shares.group_by(&:percent).size,
              source: 'Treasury')
          end

          pool_shares = @pool_shares.map do |share|
            next unless @step.can_buy?(target, share.to_bundle, borrow_from: @current_entity)

            h(Button::BuyShare,
              share: share,
              entity: @current_entity,
              purchase_for: target,
              borrow_from: @current_entity,
              percentages_available: @pool_shares.group_by(&:percent).size)
          end

          ipo_shares + treasury_shares + pool_shares
        end
      end

      def render_price_protection
        return [] unless @step.respond_to?(:price_protection)

        price_protection = @step.price_protection

        return [] unless price_protection

        protect = -> { process_action(Engine::Action::BuyShares.new(@current_entity, shares: price_protection.shares)) }

        [h(:button, { on: { click: protect } }, 'Protect Shares')]
      end

      def render_reduced_price_shares(shares, source: 'Market')
        shares.map do |share|
          next unless (swap_share = @step.swap_buy(@current_entity, @corporation, share))

          h(Button::BuyShare,
            share: share,
            swap_share: swap_share,
            entity: @current_entity,
            percentages_available: shares.group_by(&:percent).size,
            source: source)
        end
      end

      def render_short
        return [] unless @step.current_actions.include?('short')
        return [] unless @step.can_short?(@current_entity, @corporation)

        short = -> { process_action(Engine::Action::Short.new(@current_entity, corporation: @corporation)) }

        [h(:button, { on: { click: short } }, 'Short Share')]
      end

      # Allow privates or minors to be exchanged for shares if they have the ability
      def render_exchanges
        children = []
        source_entities = @game.companies + @game.minors

        source_entities.each do |entity|
          @game.abilities(entity, :exchange) do |ability|
            next unless @game.exchange_corporations(ability).include?(@corporation)
            next unless entity.owner == @current_entity

            if ability.from.include?(:ipo)
              president_share, other_ipo_shares = @ipo_shares.partition(&:president)
              children.concat(render_share_exchange(other_ipo_shares,
                                                    entity,
                                                    source: @game.ipo_name(@corporation)))
              children.concat(render_share_exchange(president_share,
                                                    entity,
                                                    source: 'Presidency'))
            end

            children.concat(render_share_exchange(@pool_shares, entity)) if ability.from.include?(:market)
            if ability.from.include?(:reserved)
              children.concat(render_share_exchange(@reserved_shares[0, 1], entity,
                                                    source: 'Reserved'))
            end
          end
        end

        children
      end

      # Put up one exchange button for each exchangable percentage share type in market.
      def render_share_exchange(shares, entity, source: 'Market')
        return [] unless @step.respond_to?(:can_gain?)

        shares.map do |share|
          next unless @step.can_gain?(entity.owner, share, exchange: true)
          next if share.president && !@game.exchange_for_partial_presidency?

          name = entity.company? ? entity.sym : entity.name
          h(Button::BuyShare,
            share: share,
            entity: entity,
            partial_percent: @game.exchange_partial_percent(share),
            percentages_available: shares.group_by(&:percent).size,
            prefix: "Exchange #{name} for ",
            source: source)
        end
      end

      def render_merge
        return [] unless @step.current_actions.include?('choose')
        return [] unless @step.respond_to?(:can_merge?)
        return [] unless @step.can_merge?(@current_entity, @corporation)

        merge = lambda do
          process_action(Engine::Action::Choose.new(@current_entity, choice: @corporation.name))
        end

        [h(:button, { on: { click: merge } }, 'Merge')]
      end

      def render_convert
        return [] unless @game.round.actions_for(@corporation).include?('convert')

        convert = -> { process_action(Engine::Action::Convert.new(@corporation)) }
        [h(:button, { on: { click: convert } }, 'Convert')]
      end
    end
  end
end
