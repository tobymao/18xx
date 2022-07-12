# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1848
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def potential_tiles(entity, hex)
            return @game.tiles.select { |tile| tile.color == 'blue' } if entity.sym == 'P3'

            super
          end
        end
      end
    end
  end
end
