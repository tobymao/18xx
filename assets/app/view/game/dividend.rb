# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class Dividend < Snabberb::Component
      include Actionable

      def render
        @step = @game.active_step

        buttons = @step.dividend_types.map do |type|
          text =
            case type
            when :payout
              'Payout'
            when :withhold
              'Withhold'
            when :half
              'Half Pay'
            else
              type
            end

          click = lambda do
            process_action(Engine::Action::Dividend.new(@step.current_entity, kind: type))
          end

          h('button.button.margined', { on: { click: click } }, text)
        end

        h(:div, [*buttons])
      end
    end
  end
end
