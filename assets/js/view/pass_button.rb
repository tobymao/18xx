# frozen_string_literal: true

require 'view/actionable'

require 'engine/action/pass'

module View
  class PassButton < Snabberb::Component
    include Actionable

    def render
      props = {
        on: {
          click: -> { process_action(Engine::Action::Pass.new(@game.current_entity)) },
        },
      }

      h(:button, props, @game.round.pass_description.to_s)
    end
  end
end
