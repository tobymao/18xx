# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Norway
      module Step
        class Token < Engine::Step::Token
          def available_hex(entity, hex)
            super(entity, hex) || harbor_available?(entity, hex)
          end

          def harbor_available?(entity, hex)
            other_hex = @game.hex_by_id(@game.harbor_city_coordinates(hex.id))
            return false unless other_hex

            @game.ferry_graph.reachable_hexes(entity)[other_hex] ||
            @game.token_graph_for_entity(entity).reachable_hexes(entity)[other_hex]
          end

          def can_place_token?(_entity)
            true
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            connected_city = @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
            if connected_city
              place_token(entity, action.city, action.token)
            elsif harbor_available?(entity, city.hex)
              @game.abilities(entity, :token) do |ability|
                place_token(entity, action.city, action.token, connected: false, special_ability: ability)
                entity.add_ability(Ability::Token.new(type: 'token', hexes: Engine::Game::G18Norway::Game::HARBOR_HEXES,
                                                      from_owner: true, discount: 0, connected: true, extra_slot: true))
              end
            else
              raise GameError, "Cannot place token on #{city.hex.name} city is not connected"
            end
            @game.clear_graph
            pass!
          end
        end
      end
    end
  end
end
