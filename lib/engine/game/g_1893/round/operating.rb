# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1893
      module Round
        class Operating < Engine::Round::Operating
          def actions_for(entity)
            # No actions available for companies during the OR
            return [] if entity.company?

            super
          end
        end
      end
    end
  end
end
