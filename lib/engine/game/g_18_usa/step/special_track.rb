# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G18USA
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include Tracker
          def hex_neighbors(entity, hex)
            # See 1817 and reinsert pittsburgh check for handling metros

            hexes = abilities(entity)&.hexes
            return if hexes&.any? && !hexes&.include?(hex.id)

            # When actually laying track entity will be the corp.
            owner = entity.corporation? ? entity : entity.owner

            @game.graph.connected_hexes(owner)[hex]
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            check_rural_junction(tile, action.hex) if tile.name.include?('Rural')

            if !@game.loading && entity&.id == 'P9' && !boomtown_company_hexes(entity.owner).include?(hex)
              raise GameError, "Cannot use #{entity.name} on #{action.hex.name} (#{action.hex.location_name})"
            end

            super
          end

          def check_rural_junction(_tile, hex)
            return unless hex.neighbors.values.any? { |h| h.tile.name.include?('Rural') }

            raise GameError, 'Cannot place rural junctions adjacent to each other'
          end

          def potential_future_tiles(_entity, hex)
            @game.tiles
              .uniq(&:name)
              .select { |t| @game.upgrades_to?(hex.tile, t) }
          end

          # The oil/coal/iron tiles falsely pass as offboards, so we need to be more careful
          def real_offboard?(tile)
            tile.offboards&.any? && !tile.labels&.any?
          end

          def available_hex(entity, hex)
            return unless (ability = abilities(entity))
            return boomtown_company_hexes(entity.owner).include?(hex) if entity.id == 'P9'
            return custom_tracker_available_hex(entity, hex, special_override: true) if \
                ability.hexes&.empty? && ability.consume_tile_lay

            hex_neighbors(entity, hex)
          end

          def potential_tiles(entity, hex)
            return [] unless (tile_ability = abilities(entity))
            return super unless %w[P9 S8].include?(tile_ability.owner.id)
            return [] unless hex.tile.color == 'yellow'

            tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
          end

          def legal_tile_rotation?(entity, hex, tile)
            # These are needed for the combo private (Keystone Bridge Co)
            return super if tile.name.include?('Rural')
            return false if tile.id.include?('iron') && !@game.class::IRON_HEXES.include?(hex.id)
            return false if tile.id.include?('coal') && !@game.class::COAL_HEXES.include?(hex.id)

            # See 1817 and reinsert pittsburgh check for handling metros
            super &&
            tile.exits.any? do |exit|
              neighbor = hex.neighbors[exit]
              ntile = neighbor&.tile
              next false unless ntile

              # The neighbouring tile must have a city or offboard or town
              # That neighbouring tile must either connect to an edge on the tile or
              # potentially be updated in future.
              # 1817 doesn't have any coal next to towns but 1817NA does and
              #  Marc Voyer confirmed that coal should be able to connect to the gray pre-printed town
              (ntile.cities&.any? || real_offboard?(ntile) || ntile.towns&.any?) &&
              (ntile.exits.any? { |e| e == Hex.invert(exit) } || potential_future_tiles(entity, neighbor).any?)
            end
          end

          def boomtown_company_hexes(corporation)
            @game.graph.connected_nodes(corporation).keys.map(&:hex).select do |node|
              @game.plain_yellow_city_tiles.find { |t| t.name == node.tile.name }
            end
          end
        end
      end
    end
  end
end
