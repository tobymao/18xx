# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Programmer
      def programmed_auto_actions(entity)
        return unless (program = @game.programmed_actions[entity.player])

        method = "activate_#{program.type}"
        return unless respond_to?(method)

        send(method, entity, program)
      end
    end
  end
end
