# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1822MX
      module Round
        class Operating < Engine::Round::Operating
          def start_operating
            entity = @entities[@entity_index]
            super unless entity.name == 'NDEM'
          end
        end
      end
    end
  end
end
