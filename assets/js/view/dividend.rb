# frozen_string_literal: true

require 'view/actionable'
require 'view/undo_and_pass'

module View
  class Dividend < Snabberb::Component
    include Actionable

    def render
      h(:div, [
        h(UndoAndPass, pass: false),
        h('button.margined', { on: { click: -> { dividend('payout') } } }, 'Payout'),
        h('button.margined', { on: { click: -> { dividend('withhold') } } }, 'Withhold'),
      ])
    end

    def dividend(type)
      process_action(Engine::Action::Dividend.new(@game.current_entity, type))
    end
  end
end
