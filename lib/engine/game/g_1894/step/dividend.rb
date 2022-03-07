# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1894
      module Step
        class Dividend < Engine::Step::Dividend
          def holder_for_corporation(entity)
            entity
          end
        end
      end
    end
  end
end
