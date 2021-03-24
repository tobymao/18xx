# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1817WO
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            # super.process_place_token modifies token; grab corporation out of it first
            corporation = token.corporation
            super
            @game.place_second_token(corporation)
          end
        end
      end
    end
  end
end
