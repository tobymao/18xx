# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class CorporateBuyShares < Snabberb::Component
      include Actionable

      needs :game, store: true

      def render
        @step = @game.round.active_step
        @current_actions = @step.current_actions
        @entity ||= @game.current_entity
        children = []

        children.concat(render_sources) if @step.current_actions.include?('corporate_buy_shares')

        h('div.margined', children.compact)
      end

      def render_sources
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        @step.source_list(@entity).map do |source|
          children = []
          if source.player?
            children << h(Player, player: source, game: @game)
            children << render_player_input(source)
          elsif source.corporation? && @game.corporation_available?(source)
            children << h(Corporation, corporation: source)
            children << render_corporation_input(source)
          end
          h(:div, props, children)
        end.compact
      end

      def render_player_input(player)
        return unless @step.current_actions.include?('corporate_buy_shares')

        input = []
        player.shares.group_by(&:corporation).values.each do |corp_shares|
          input << render_player_buttons(corp_shares.group_by(&:percent).values.map(&:first))
        end

        h('div.margined_bottom', { style: { width: '20rem' } }, input.compact)
      end

      def render_player_buttons(shares)
        children = []

        shares
          .select { |share| @step.can_buy?(@entity, share.to_bundle) }
          .each do |share|
            corp = share.corporation.name
            text = shares.size > 1 ? "Buy #{share.percent}% #{corp} Share" : "Buy #{corp} Share"
            children << h(:button, { on: { click: -> { buy_share(@entity, share) } } }, text)
          end

        h(:div, children) if children.any?
      end

      def render_corporation_input(corporation)
        return unless @step.current_actions.include?('corporate_buy_shares')

        pool_shares = @game.share_pool.shares_by_corporation[corporation].group_by(&:percent).values.map(&:first)
        input = [render_corporation_buttons(pool_shares)]

        h('div.margined_bottom', { style: { width: '20rem' } }, input.compact)
      end

      def render_corporation_buttons(shares)
        children = []

        shares
          .select { |share| @step.can_buy?(@entity, share.to_bundle) }
          .each do |share|
            text = shares.size > 1 ? "Buy #{share.percent}% Market Share" : 'Buy Market Share'
            children << h(:button, { on: { click: -> { buy_share(@entity, share) } } }, text)
          end

        h(:div, children) if children.any?
      end

      def buy_share(entity, share)
        process_action(Engine::Action::CorporateBuyShares.new(entity, shares: share))
      end
    end
  end
end
