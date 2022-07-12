# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1848
      module Step
        class Dividend < Engine::Step::Dividend
          def corporation_dividends(_entity, _per_share)
            0
          end
        end
      end
    end
  end
end
