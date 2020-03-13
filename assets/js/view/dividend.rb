# frozen_string_literal: true

require 'view/actionable'

require 'engine/action/dividend'

module View
  class Dividend < Snabberb::Component
    include Actionable

    def render
      h(:div, [
        h(:button, { on: { click: -> { dividend(:payout) } } }, 'Payout'),
        h(:button, { on: { click: -> { dividend(:withhold) } } }, 'Withhold'),
      ])
    end

    def dividend(type)
      process_action(Engine::Action::Dividend.new(@game.current_entity, type))
    end
  end
end
