# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Programmer
      def programmed_auto_actions(entity)
        return if (p_list = @game.programmed_actions[entity.player]).empty?

        a_list = []
        p_list.each do |program|
          method = "activate_#{program.type}"
          next unless respond_to?(method)

          new_actions = send(method, entity, program)
          a_list.concat(new_actions) if new_actions
        end
        a_list
      end
    end
  end
end
