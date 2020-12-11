# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/sell_shares'

module View
  module Game
    class CorporateSellShares < Snabberb::Component
      include Actionable

      def render
        @step = @game.round.active_step
        current_actions = @step.current_actions
        @entity ||= @game.current_entity
        children = []

        children.concat(render_sources) if current_actions.include?('corporate_sell_shares')

        h('div.margined', children.compact)
      end

      def render_sources
        @step.source_list(@entity).flat_map do |source|
          [
            h(Corporation, corporation: source),
            h(SellShares,
              player: @entity,
              corporation: source,
              action: Engine::Action::CorporateSellShares),
          ]
        end
      end
    end
  end
end
