# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1862
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?
            return [] if @game.skip_round[entity] || @game.lner

            super
          end

          def log_skip(entity)
            super unless @game.skip_round[entity]
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            tile_lay = get_tile_lay(action.entity)
            raise GameError, "Cannot lay an 'N' tile now" if action.tile.label.to_s == 'N' && !(tile_lay && tile_lay[:upgrade])

            super
          end

          def track_upgrade?(_from, to, _hex)
            # this also takes care of adding small stations, since that is never yellow to yellow
            to.color != :yellow || to.label.to_s == 'N'
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            super unless @game.adding_town?(old_tile, new_tile)
          end

          def update_tile_lists(tile, old_tile)
            raise GameError, 'tile already laid' unless @game.tiles.include?(tile)

            @game.tiles.delete(tile)
            @game.tiles << old_tile unless old_tile.preprinted

            return unless tile.cities.empty? && tile.color != old_tile.color && tile.color != :yellow

            # if an upgrade without cities => remove/restore base tile
            new_base_name = @game.base_tile_name(tile)
            new_base_tile = @game.tiles.find { |t| t.name == new_base_name }
            @game.tiles.delete(new_base_tile)
            @game.base_tiles << new_base_tile

            return unless old_tile.color != :yellow

            old_base_name = @game.base_tile_name(old_tile)
            old_base_tile = @game.base_tiles.find { |t| t.name == old_base_name }
            @game.base_tiles.delete(old_base_tile)
            @game.tiles << old_base_tile
          end

          def potential_tiles(entity, hex)
            colors = @game.phase.tiles
            normal = normal_available_hex(entity, hex)

            @game.tiles
              .select { |tile| colors.include?(tile.color) }
              .uniq(&:name)
              .select { |t| normal ? @game.upgrades_to?(hex.tile, t) : @game.adding_town?(hex.tile, t) }
              .reject(&:blocks_lay)
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.adding_town?(hex.tile, tile)

            # Here on out only used for adding towns
            #
            # Test to make sure that when a town is added it only replaces
            # one simple path from edge to edge and does nothing else
            old_ctedges = hex.tile.city_town_edges.map(&:sort)
            old_exits = hex.tile.exits

            new_exits = tile.exits
            new_ctedges = tile.city_town_edges.map(&:sort)

            extra_ctedges = (new_ctedges - old_ctedges).flatten
            old_simple_exits = old_exits - old_ctedges.flatten
            new_simple_exits = new_exits - new_ctedges.flatten
            simple_exit_diff = old_simple_exits - new_simple_exits

            extra_cities = [0, new_ctedges.size - old_ctedges.size].max

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              # only adding one new town
              (extra_cities == 1) &&
              # all existing town paths are kept
              ((old_ctedges & new_ctedges).size == old_ctedges.size) &&
              # new town only replaces simple paths
              extra_ctedges.all? { |edge| simple_exit_diff.include?(edge) } &&
              simple_exit_diff.all? { |edge| extra_ctedges.include?(edge) }
          end

          def normal_available_hex(entity, hex)
            available_hex(entity, hex, normal: true)
          end

          def available_hex(entity, hex, normal: false)
            return nil if @game.class::LONDON_TOKEN_HEXES.include?(hex.id) # never highlight the London hexes

            color = hex.tile.color
            num_towns = hex.tile.towns.size
            num_cities = hex.tile.cities.size
            # allow adding towns to unconnected plain/town tiles
            connected = hex_neighbors(entity, hex) ||
              (!normal && (color == :green && num_cities.zero? && num_towns < 2)) ||
              (!normal && (color == :brown && num_cities.zero? && num_towns < 3))
            return nil unless connected

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            connected
          end
        end
      end
    end
  end
end
