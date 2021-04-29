# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1840
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            return [] if entity.company? || routes.empty?

            ACTIONS
          end
        end
      end
    end
  end
end
