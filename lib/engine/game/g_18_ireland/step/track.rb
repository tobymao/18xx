# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Ireland
      module Step
        class Track < Engine::Step::Track
          include NarrowTrack
          def hex_neighbors(entity, hex)
            all_hex_neighbors(entity, hex)
          end
        end
      end
    end
  end
end
