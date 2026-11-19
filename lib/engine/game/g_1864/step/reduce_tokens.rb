# frozen_string_literal: true

require_relative '../../g_1867/step/reduce_tokens'

module Engine
  module Game
    module G1864
      module Step
        class ReduceTokens < G1867::Step::ReduceTokens
          def can_replace_token?(entity, token)
            super && !@game.extra_station?(token)
          end

          def process_remove_token(action)
            city = action.city
            token = (city.tokens + city.extra_tokens)[action.slot]
            raise GameError, 'Union and Central Stations are not part of the merger' if @game.extra_station?(token)

            super
            @game.attach_extra_stations!(action.entity) unless @round.corporations_removing_tokens
          end
        end
      end
    end
  end
end
