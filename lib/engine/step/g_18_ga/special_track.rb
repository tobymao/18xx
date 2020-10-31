# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G18GA
      class SpecialTrack < SpecialTrack
        def tile_lay_abilities(entity, &block)
          ability = super

          ability if ability &&
            entity.owner == @game.round.current_entity &&
            @game.round.active_step.respond_to?(:process_lay_tile)
        end
      end
    end
  end
end
