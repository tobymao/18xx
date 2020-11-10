# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class BuySpecial < Snabberb::Component
      include Actionable
      needs :entity, default: nil

      def render
        @entity ||= @game.current_entity
        @step = @game.round.step_for(@entity, 'buy_special')

        h('div.margined', [render_items(@step.items)])
      end

      def render_items(items)
        rendered_items = items.map do |item|
          render_button(item) do
            process_action(Engine::Action::BuySpecial.new(@entity, item: item))
          end
        end

        h('div.inline-block', rendered_items)
      end

      def render_button(item, &block)
        h(:button, { on: { click: block } }, "Buy #{item.description} (#{@game.format_currency(item.cost)})")
      end
    end
  end
end
