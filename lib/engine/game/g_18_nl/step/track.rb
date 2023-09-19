# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18NL
      module Step
        class Track < Engine::Step::Track
          def available_hex(entity_or_entities, hex)
            return false if hex.id == 'H13' && !@game.nzo_has_placed_home?

            super
          end
        end
      end
    end
  end
end
