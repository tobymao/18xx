# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    # Base for the small "Auto pass" buttons next to Pass that arm a
    # program-enable action for the current entity. Subclasses supply
    # `program_action`.
    class ProgramAutoButton < Snabberb::Component
      include Actionable

      def render
        props = { on: { click: -> { process_action(program_action(@game.current_entity)) } } }
        h(:button, props, 'Auto pass')
      end
    end
  end
end
