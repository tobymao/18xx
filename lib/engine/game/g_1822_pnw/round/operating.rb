# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../step/route'

module Engine
  module Game
    module G1822PNW
      module Round
        class Operating < Engine::Round::Operating
          def start_operating
            return force_next_entity! if @game.regional_railway?(@entities[@entity_index])

            super
          end
        end
      end
    end
  end
end
