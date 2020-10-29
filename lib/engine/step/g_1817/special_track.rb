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
            ability(action.entity).use!
          end
          step.laid_track = step.laid_track + 1
        end
      end
    end
  end
end
