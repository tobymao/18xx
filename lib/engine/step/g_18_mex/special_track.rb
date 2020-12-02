# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G18Mex
      class SpecialTrack < SpecialTrack
        COPPER_CANYON = '470'

        def tile_lay_abilities(entity)
          ability = super

          ability if ability &&
            entity.owner == @game.round.current_entity &&
            @game.round.active_step.respond_to?(:process_lay_tile) &&
            copper_canyon_hex_empty?(ability)
        end

        def process_lay_tile(action)
          super
          return unless action.tile.name == COPPER_CANYON

          action.tile.label = nil
          @game.log << "#{@game.p2_company.name} closes"
          @game.p2_company.close!
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
