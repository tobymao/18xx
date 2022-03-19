# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18NewEngland
      module Round
        class Operating < Engine::Round::Operating
          def recalculate_order
            recalculate_majors_order
          end
        end
      end
    end
  end
end
