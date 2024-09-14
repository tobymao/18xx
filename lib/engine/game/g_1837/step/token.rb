# frozen_string_literal: true

require_relative '../../../step/token'
require_relative '../../../minor'

module Engine
  module Game
    module G1837
      module Step
        class Token < Engine::Step::Token
          def skip!
            super unless @round.current_operator.is_a?(Minor)
          end
        end
      end
    end
  end
end
