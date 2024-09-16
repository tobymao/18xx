# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18ESP
      module Round
        class Operating < Engine::Round::Operating
          def start_operating
            if current_entity.corporation? && current_entity.tokens.first&.used &&
                @game.check_for_destination_connection(current_entity)
              current_entity.goal_reached!(:destination)
            end
            super
          end
        end
      end
    end
  end
end
