# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18PA
      module Step
        class Track < Engine::Step::Track
          def potential_tile_colors(entity, hex)
            return @game.class::MINOR_UPGRADES if entity.minor? && @game.phase.name != '2'

            super
          end
        end
      end
    end
  end
end
