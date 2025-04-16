# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1837
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            corporation = token.corporation
            super
            Array(corporation.coordinates).each { |coords| @game.remove_reservation!(corporation, coords) }
          end
        end
      end
    end
  end
end
