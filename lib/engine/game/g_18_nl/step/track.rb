# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18NL
      module Step
        class Track < Engine::Step::Track
          def available_hex(entity_or_entities, hex)
            # No corp may upgrade H13 until NZO's home token has been placed.
            return false if hex.id == @game.class::NZO_HOME_HEX && !@game.nzo_has_placed_home?

            super
          end
        end
      end
    end
  end
end
