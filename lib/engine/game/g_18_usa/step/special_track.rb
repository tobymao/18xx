# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18USA
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def hex_neighbors(entity, hex)
            # See 1817 and reinsert pittsburgh check for handling metros

            return false unless (ability = abilities(entity))

            hexes = ability.hexes
            return hex.neighbors.keys if hexes.include?(hex.id) && !ability.reachable
            return if hexes&.any? && !hexes&.include?(hex.id)

            # When actually laying track entity will be the corp.
            owner = entity.corporation? ? entity : entity.owner

            @game.graph.connected_hexes(owner)[hex]
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            check_rural_junction(tile, action.hex) if @game.class::RURAL_TILES.include?(tile.name)

            if !@game.loading && entity&.id == 'P9' && !boomtown_company_hexes(entity.owner).include?(hex)
              raise GameError, "Cannot use #{entity.name} on #{action.hex.name} (#{action.hex.location_name})"
            end

            super
            return if action.entity.id != 'P17' || !@game.resource_tile?(tile)

            # Consume the resource used for the tile lay
            resource_company = action.entity.owner.companies.find do |c|
              c.id != 'P17' && abilities(c)&.tiles&.include?(tile.name)
            end
            raise GameError, "#{action.entity.name} cannot lay resource tile" unless resource_company

            @game.log << "#{resource_company.name} contributes the resource"
            ability = abilities(resource_company)
            ability.use!
            return if !ability.count&.zero? || !ability.closed_when_used_up

            @log << "#{resource_company.name} closes"
            resource_company.close!
          end

          def check_rural_junction(_tile, hex)
            return unless hex.neighbors.values.any? { |h| @game.class::RURAL_TILES.include?(h.tile.name) }

            raise GameError, 'Cannot place rural junctions adjacent to each other'
          end

          def potential_future_tiles(_entity, hex)
            @game.tiles
              .uniq(&:name)
              .select { |t| @game.upgrades_to?(hex.tile, t) }
          end

          # The oil/coal/ore tiles falsely pass as offboards, so we need to be more careful
          def real_offboard?(tile)
            tile.offboards&.any? && !tile.labels&.any?
          end

          def available_hex(entity, hex)
            return boomtown_company_hexes(entity.owner).include?(hex) if entity.id == 'P9'

            hex_neighbors(entity, hex)
          end

          def legal_tile_rotation?(entity, hex, tile)
            # See 1817 and reinsert pittsburgh check for handling metros
            return super unless @game.resource_tile?(tile)

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
