# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G1870
      class SpecialTrack < SpecialTrack
        def process_lay_tile(action)
          step = @round.active_step
          raise 'Can only be laid as part of lay track' unless step.is_a?(Step::Track)

          owner = action.entity.owner
          tile = action.tile
          tile_lay = step.get_tile_lay(owner)
          @game.game_error('Can only be used to lay yellow tiles') if tile.color != :yellow || !tile_lay[:lay]

          extra_cost = tile_lay[:cost] - 40
          extra_cost -= 20 if owner == @game.ssw_corporation && action.hex.name == 'H17'

          lay_tile(action, extra_cost: extra_cost, entity: action.entity, spender: owner)

          ability = tile_lay_abilities(action.entity)
          ability.use!

          if @game.river_corporations.include?(owner) && !owner.operated?
            @round.river_special_tile_lay = tile.hex
          else
            step.laid_track = step.laid_track + 1
          end
        end
      end
    end
  end
end
