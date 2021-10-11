# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module ProgrammerMergerPass
      include Programmer
      def auto_actions(entity)
        programmed_auto_actions(entity)
      end

      def activate_program_merger_pass(entity, program)
        if @game.actions.last != program && program.options&.include?('disable_others') && others_acted?
          return [Action::ProgramDisable.new(entity.player,
                                             reason: 'Other players have acted and requested to stop')]
        end

        pass_entity = merger_auto_pass_entity
        return unless pass_entity

        # Check to see if the round and corps include the current one
        return unless program.corporations_by_round&.dig(@round.class.short_name)&.include?(pass_entity)

        # Corporation and round matchs, pass!
        [Action::Pass.new(entity)]
      end
    end
  end
end
