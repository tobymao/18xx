# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G18Mex
      class SpecialTrack < SpecialTrack
        COPPER_CANYON = '470'

        def ability(entity)
          ability = super

          ability if ability &&
            entity.owner == @game.round.current_entity &&
            @game.round.active_step.respond_to?(:process_lay_tile) &&
            copper_canyon_hex_empty?(ability)
        end

        def process_lay_tile(action)
          super
          action.tile.label = nil if action.hex.tile.name == COPPER_CANYON
        end

        private

        def copper_canyon_hex_empty?(ability)
          @copper_canyon_hex ||= @game.hex_by_id(ability.hexes.first)
          @copper_canyon_hex.tile.color == :white
        end
      end
    end
  end
end
