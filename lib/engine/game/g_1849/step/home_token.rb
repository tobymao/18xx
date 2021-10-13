# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1849
      module Step
        class HomeToken < Engine::Step::HomeToken
          def active_entities
            [current_entity]
          end
        end
      end
    end
  end
end
