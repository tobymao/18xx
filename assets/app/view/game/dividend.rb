# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class Dividend < Snabberb::Component
      include Actionable

      def render
        h(:div, [
          h(UndoAndPass, pass: false),
          h('button.button.margined', { on: { click: -> { dividend('payout') } } }, 'Payout'),
          h('button.button.margined', { on: { click: -> { dividend('withhold') } } }, 'Withhold'),
        ])
      end

      def dividend(type)
        process_action(Engine::Action::Dividend.new(@game.current_entity, type))
      end
    end
  end
end
