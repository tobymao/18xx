# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18FL
      module Step
        class Track < Engine::Step::Track
          def can_lay_tile?(entity)
            super || !@game.tile_company.closed?
          end
        end
      end
    end
  end
end
