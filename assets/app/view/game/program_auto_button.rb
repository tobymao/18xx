# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    # The small "Auto pass" button next to Pass that arms a program-enable
    # action for the current entity. `program_action_class` supplies which one.
    class ProgramAutoButton < Snabberb::Component
      include Actionable

      needs :program_action_class

      def render
        props = { on: { click: -> { process_action(@program_action_class.new(@game.current_entity)) } } }
        h(:button, props, 'Auto pass')
      end
    end
  end
end
