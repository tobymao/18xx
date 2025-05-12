# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18PA
      module Step
        class Track < Engine::Step::Base
          def potential_tile_colors(entity, hex)
            return @game.class::MINOR_UPGRADES if entity.corporation? &&
                                                  entity.type == :minor &&
                                                  @game.phase.name != '2'

            super
          end
        end
      end
    end
  end
end
