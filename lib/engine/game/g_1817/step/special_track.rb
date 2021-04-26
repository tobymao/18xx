# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1817
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            tile = action.tile
            owner = action.entity.owner
            super
            return if action.entity.id == @game.class::PITTSBURGH_PRIVATE_NAME

            tile.hex.assign!('mine')
            @game.log << "#{owner.name} adds mine to #{tile.hex.name}"
          end

          def hex_neighbors(entity, hex)
            return super if entity.company? && entity.id == @game.class::PITTSBURGH_PRIVATE_NAME

            hexes = abilities(entity)&.hexes
            return if hexes&.any? && !hexes&.include?(hex.id)

            # When actually laying track entity will be the corp.
            owner = entity.corporation? ? entity : entity.owner

            @game.graph.connected_hexes(owner)[hex]
          end

          def potential_future_tiles(_entity, hex)
            @game.tiles
              .uniq(&:name)
              .select { |t| @game.upgrades_to?(hex.tile, t) }
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super if entity.company? && entity.id == @game.class::PITTSBURGH_PRIVATE_NAME

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
              (ntile.cities&.any? || ntile.offboards&.any? || ntile.towns&.any?) &&
              (ntile.exits.any? { |e| e == Hex.invert(exit) } || potential_future_tiles(entity, neighbor).any?)
            end
          end
        end
      end
    end
  end
end
