# frozen_string_literal: true

require_relative 'base'
module Engine
  module Round
    class LegacyBase < Base
      def active_entities
        [@current_entity] + crowded_corps
      end

      def process_action(action)
        entity = action.entity
        return @log << action if action.is_a?(Action::Message)
        raise GameError, 'Game has ended' if @game.finished

        if action.is_a?(Action::EndGame)
          @log << '-- Game ended by player --'
          return @game.end_game!
        end

        raise GameError, "It is not #{entity.name}'s turn" unless can_act?(entity)

        if action.pass?
          log_pass(entity)
          pass(action)
          pass_processed(action)
        else
          _process_action(action)
          action_processed(action)
        end
        change_entity(action)
        action_finalized(action)
      end
    end
  end
end
