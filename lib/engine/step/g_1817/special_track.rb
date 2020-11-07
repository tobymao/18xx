# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G1817
      class SpecialTrack < SpecialTrack
        def process_lay_tile(action)
          step = @round.active_step
          raise 'Can only be laid as part of lay track' unless step.is_a?(Step::Track)

          if action.entity.id == 'PSM'
            super
          else # Mine
            owner = action.entity.owner
            tile_lay = step.get_tile_lay(owner)
            tile = action.tile
            @game.game_error('Cannot lay an yellow now') if tile.color == :yellow && !tile_lay[:lay]
            # Subtract 15 from the cost cancelling the terrain cost
            lay_tile(action, extra_cost: tile_lay[:cost] - 15, entity: owner, spender: owner)
            tile.hex.assign!('mine')
            @game.log << "#{owner.name} adds mine to #{tile.hex.name}"
            tile_lay_abilities(action.entity).use!
          end
          step.laid_track = step.laid_track + 1
        end

        def available_hex(entity, hex)
          return super if entity.company? && entity.id == 'PSM'

          hexes = tile_lay_abilities(entity)&.hexes
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
          return super if entity.company? && entity.id == 'PSM'

          super &&
          tile.exits.any? do |exit|
            neighbor = hex.neighbors[exit]
            ntile = neighbor&.tile
            next false unless ntile

            # The neighbouring tile must have a city or offboard
            # That neighbouring tile must either connect to an edge on the tile or
            # potentially be updated in future.
            (ntile.cities&.any? ||
             ntile.offboards&.any?) &&
            (ntile.edges.any? { |e| e.num == Hex.invert(exit) } ||
             potential_future_tiles(entity, neighbor).any?)
          end
        end
      end
    end
  end
end
