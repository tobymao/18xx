# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'resource_track'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include ResourceTrack
          include P11Track

          def can_lay_tile?(entity)
            super || can_place_token_with_p20?(entity) || can_assign_p6?(entity)
          end

          def can_place_token_with_p20?(entity)
            entity.companies.include?(@game.company_by_id('P20')) &&
            !entity.tokens.all?(&:used) &&
            @game.graph.connected_nodes(entity).keys.any? do |node|
              node.city? && node.available_slots.zero? && !node.tokened_by?(entity) &&
                !@game.class::COMPANY_TOWN_TILES.include?(node.tile.name)
            end
          end

          def can_assign_p6?(entity)
            entity.companies.include?(@game.company_by_id('P6')) &&
            @game.graph.connected_hexes(entity).keys.any? { |hex| hex.tile.color == :red }
          end

          def legal_tile_rotation?(entity, hex, tile)
            return true if tile.name == 'X23'

            super
          end

          def process_lay_tile(action)
            return super unless free_brown_city_upgrade?(action.entity, action.hex, action.tile)

            lay_tile(action)
            @round.laid_hexes << action.hex
          end

          def free_brown_city_upgrade?(entity, hex, tile)
            !entity.operated? && @game.home_hex_for(entity) == hex && tile.color == :brown
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex
            previous_tile = hex.tile
            entity ||= action.entity

            if previous_tile.cities.empty? && tile.color != previous_tile.color
              extra_cost += 10 * (Engine::Tile::COLORS.index(tile.color) - Engine::Tile::COLORS.index(previous_tile.color) - 1)
            end

            super(action, extra_cost: extra_cost, entity: entity, spender: spender)

            if @game.metro_denver && @game.hex_by_id('E11').tile.name == 'X04s' &&
                hex.neighbors.any? { |exit, h| hex.tile.exits.include?(exit) && h.name == 'E11' }
              @round.pending_tracks << { entity: entity, hexes: [@game.hex_by_id('E11')] }
            end
            @game.jump_graph.clear
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            old_tile.name.include?('ore') && new_tile.name.include?('ore') ? true : super
          end

          def track_upgrade?(from, to, _hex)
            super ||
            (from.cities.empty? && (Engine::Tile::COLORS.index(to.color) - Engine::Tile::COLORS.index(from.color) > 1))
          end
        end
      end
    end
  end
end
