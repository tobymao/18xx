# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18VA
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            actions = super
            return actions if !actions.empty? || @game.token_company.closed? || @game.token_company.owner != entity

            %w[pass]
          end
        end
      end
    end
  end
end
