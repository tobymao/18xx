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
        pass_entity = merger_auto_pass_entity
        return unless pass_entity

        # Check to see if the round and corps include the current one
        return unless program.rounds.include?(@round.class.short_name)
        return unless program.corporations.include?(pass_entity)

        # Corporation and round matchs, pass!
        [Action::Pass.new(entity)]
      end
    end
  end
end
