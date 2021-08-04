# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18CZ
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            # the ATE home token can be placed again, and in that time the corporation could have more tokens.
            # The Home Token should always be free
            token.price = 0
            super
          end
        end
      end
    end
  end
end
