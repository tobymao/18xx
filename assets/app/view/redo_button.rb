# frozen_string_literal: true

require 'view/actionable'

module View
  class RedoButton < Snabberb::Component
    include Actionable

    def render
      props = {
        on: {
          click: -> { process_action(Engine::Action::Redo.new(@game.current_entity)) },
        },
        style: {
          'margin-right': '1em',
        },
      }

      h(:button, props, 'Redo')
    end
  end
end
