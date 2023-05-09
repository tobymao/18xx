# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1847AE
      module Step
        class Track < Engine::Step::Track
          def available_hex(entity, hex)
            return nil if (hex.id == 'E9') && !@game.can_build_in_e9?

            super
          end
        end
      end
    end
  end
end
