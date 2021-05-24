# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1862
      module Step
        class HomeUpgrade < Engine::Step::Track
          def round_state
            super.merge(
              {
                upgrade_before_token: [],
              }
            )
          end

          def description
            'Upgrade home hex'
          end

          # be silent
          def skip!
            pass!
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity && @round.upgrade_before_token.include?(entity)
            return [] if entity.company?

            %w[lay_tile]
          end

          def process_lay_tile(action)
            lay_tile_action(action)

            add_token(action.hex, action.entity)
            @round.upgrade_before_token.delete(action.entity)
            @game.graph.clear
            pass!
          end

          def add_token(hex, entity)
            token = entity.find_token_by_type
            hex.tile.cities.first.place_token(entity, token)
            @game.remove_marker(entity)
            @log << "#{entity.name} places home token on #{hex.name}"
          end

          def check_track_restrictions!(_entity, _old_tile, _new_tile); end

          # no graph at this point -> use other company on hex (there has to be one)
          def hex_neighbors(_entity, hex)
            other = hex.tile.cities.first.tokens.find { |t| t }.corporation
            @game.graph_for_entity(other).connected_hexes(other)[hex]
          end

          # no graph at this point -> allow lay on home hex
          def available_hex(entity, hex)
            return nil unless entity.corporation?

            hex == @game.hex_by_id(entity.coordinates)
          end
        end
      end
    end
  end
end
