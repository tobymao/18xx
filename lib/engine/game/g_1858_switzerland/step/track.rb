# frozen_string_literal: true

require_relative '../../g_1858/step/track'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class Track < G1858::Step::Track
          ROBOT_ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return super unless @game.robot_owner?(entity)
            return [] if @game.home_route_complete?(entity)
            return [] if home_cities_upgraded?(entity)

            ROBOT_ACTIONS
          end

          def help
            operator = current_entity
            return super unless @game.robot_owner?(operator)

            name = @game.acting_for_robot(operator).name
            if operator.corporation?
              "#{name} must upgrade one of the cities where #{operator.id} " \
                'has a station token.'
            else
              "#{name} must build track in one of #{operator.id}’s home hexes."
            end
          end

          def available_hex(entity, hex)
            return super unless @game.robot_owner?(entity)

            if entity.corporation?
              entity.placed_tokens.any? { |t| t.city.tile.hex == hex } &&
                tile_upgradeable?(hex.tile)
            else
              entity.coordinates.include?(hex.coordinates) &&
                hex.tile.color == :white
            end
          end

          private

          def home_cities_upgraded?(entity)
            return false unless entity.corporation?

            city_tiles = entity.placed_tokens.map(&:city).map(&:tile)
            city_tiles.none? { |tile| tile_upgradeable?(tile) }
          end

          def tile_upgradeable?(tile)
            colors = potential_tile_colors(current_entity, tile.hex)
            @game.all_tiles.any? do |upgrade|
              @game.tile_valid_for_phase?(upgrade, phase_color_cache: colors) &&
                tile.paths_are_subset_of?(upgrade.paths) &&
                @game.upgrades_to_correct_color?(tile, upgrade) &&
                @game.upgrades_to_correct_label?(tile, upgrade) &&
                @game.upgrades_to_correct_city_town?(tile, upgrade)
            end
          end
        end
      end
    end
  end
end
