# frozen_string_literal: true

require 'view/actionable'

module View
  class PassButton < Snabberb::Component
    include Actionable

    def render
      props = {
        on: {
          click: -> { process_action(Engine::Action::Pass.new(@game.current_entity)) },
        },
      }

      h(:button, props, @game.round.pass_description)
    end
  end
end
