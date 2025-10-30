# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class PassAutoButton < Snabberb::Component
      include Actionable

      # Return truthy to proceed, false or :halt to cancel
      needs :before_process_pass, default: -> { true }, store: true

      def render
        props = {
          on: {
            click: lambda do
              proceed = @before_process_pass.call
              process_action(Engine::Action::ProgramSharePass.new(@game.current_entity)) unless [false, :halt].include?(proceed)
            end,
          },
        }

        h(:button, props, 'Auto pass')
      end
    end
  end
end
