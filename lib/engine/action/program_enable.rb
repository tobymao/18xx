# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class ProgramEnable < Base
      # Is the game state such that the program should be disabled
      def disable?(_game)
        true
      end
    end
  end
end
