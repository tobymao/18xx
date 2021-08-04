# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18CZ
      module Step
        class Token < Engine::Step::Token
          def buying_power(entity)
            @game.token_buying_power(entity)
          end
        end
      end
    end
  end
end
