# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1858
      module Step
        class Dividend < Engine::Step::Dividend
          def rust_obsolete_trains!(entity)
            # Wounded trains are not discarded after running
          end
        end
      end
    end
  end
end
