# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18NL
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            actions = super
            # P2's tokening ability gets skipped without a connection to a token. This gives a blocking step for the owning corp.
            return actions if !actions.empty? || @game.p2_company.closed? || @game.p2_company.owner != entity

            %w[pass]
          end
        end
      end
    end
  end
end
