# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1870
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            step = @round.active_step
            raise 'Can only be laid as part of lay track' unless step.is_a?(Engine::Step::Track)

            owner = action.entity.owner
            tile = action.tile
            tile_lay = step.get_tile_lay(owner)
            raise GameError, 'Can only be used to lay yellow tiles' if tile.color != :yellow || !tile_lay[:lay]

            extra_cost = tile_lay[:cost] - 40
            extra_cost -= 20 if owner == @game.ssw_corporation && action.hex.name == 'H17' && !owner.operated?

            lay_tile(action, extra_cost: extra_cost, entity: action.entity, spender: owner)

            ability = abilities(action.entity)
            ability.use!

            if @game.river_corporations.include?(owner) && !owner.operated? && @game.home_hex(owner) == tile.hex
              @round.river_special_tile_lay = tile.hex
            else
              @round.num_laid_track = @round.num_laid_track + 1
            end
          end
        end
      end
    end
  end
end
