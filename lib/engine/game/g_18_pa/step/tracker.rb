# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18PA
      module Tracker
        include Engine::Step::Tracker

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
