# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18OE
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return ACTIONS if entity == current_entity && !@round.tokened && @game.abilities(entity, :token)

            super
          end

          def available_hex(entity, hex)
            return nil unless @game.city_in_track_rights?(entity, hex)

            super
          end

          def check_connected(entity, city, hex)
            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            unless @game.city_in_track_rights?(entity, hex)
              raise GameError, "Cannot place token on #{hex.name} because it is outside #{entity.name}'s track rights zone"
            end

            return if @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]

            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end
        end
      end
    end
  end
end
