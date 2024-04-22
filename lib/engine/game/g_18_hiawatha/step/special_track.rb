# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18Hiawatha
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            tile = action.tile
            corporation = action.entity.owner
            company = action.entity
            super

            return unless company == @game.farmers_union

            tile.hex.assign!('farm')
            @game.log << "#{corporation.name} adds farm to #{tile.hex.name}"
          end

          def potential_tile_colors(entity, hex)
            colors = super
            return colors if colors.include?(:green)

            colors << :green if entity == @game.jlbc && hex.id == @game.jlbc_home
            colors
          end
        end
      end
    end
  end
end
