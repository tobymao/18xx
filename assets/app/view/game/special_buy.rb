# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class SpecialBuy < Snabberb::Component
      include Actionable
      needs :entity, default: nil

      def render
        @entity ||= @game.current_entity
        @step = @game.round.step_for(@entity, 'special_buy')

        h('div.margined', [render_items(@step.buyable_items(@entity))])
      end

      def render_items(items)
        rendered_items = items.map do |item|
          render_button(item) do
            process_action(Engine::Action::SpecialBuy.new(@entity, item: item))
          end
        end

        h('div.inline-block', rendered_items)
      end

      def render_button(item, &block)
        text = if @step.respond_to?(:item_str)
                 @step.item_str(item)
               else
                 "Buy #{item.description} (#{@game.format_currency(item.cost)})"
               end
        h(:button, { on: { click: block } }, text)
      end
    end
  end
end
