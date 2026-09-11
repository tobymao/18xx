# frozen_string_literal: true

require 'view/game/program_auto_button'

module View
  module Game
    class PassAutoButton < ProgramAutoButton
      def program_action(entity)
        Engine::Action::ProgramSharePass.new(entity)
      end
    end
  end
end
