# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/button/buy_share'

module View
  module Game
    class CorporateBuyShares < Snabberb::Component
      include Actionable

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
          next if source.corporation? && !@game.corporation_available?(source)

          children = []
          if source.player?
            children << h(Player, player: source, game: @game)
            children << render_player_input(source)
          elsif source.corporation?
            children << h(Corporation, corporation: source)
            children << render_corporation_input(source)
          end
          h(:div, props, children)
        end.compact
      end

      def render_player_input(player)
        return unless @step.current_actions.include?('corporate_buy_shares')

        input = player.shares.group_by(&:corporation).values.map do |corp_shares|
          render_buttons(corp_shares.group_by(&:percent).values.map(&:first),
                         source: corp_shares.first.corporation.name)
        end.compact

        h('div.margined_bottom', { style: { width: '20rem' } }, input) if input.any?
      end

      def render_corporation_input(corporation)
        return unless @step.current_actions.include?('corporate_buy_shares')

        pool_shares = @game.share_pool.shares_by_corporation[corporation].group_by(&:percent).values.map(&:first)
        input = [render_buttons(pool_shares)].compact

        h('div.margined_bottom', { style: { width: '20rem' } }, input) if input.any?
      end

      def render_buttons(shares, source: 'Market')
        children = shares.map do |share|
          next unless @step.can_buy?(@entity, share.to_bundle)

          h(Button::BuyShare,
            share: share,
            entity: @entity,
            source: source,
            percentages_available: shares.size,
            action: Engine::Action::CorporateBuyShares)
        end.compact

        h(:div, children) if children.any?
      end
    end
  end
end
