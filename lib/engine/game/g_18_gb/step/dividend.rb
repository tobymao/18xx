# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18GB
      module Step
        class Dividend < Engine::Step::Dividend
          def holder_for_corporation(entity)
            return entity
          end
        end
      end
    end
  end
end
