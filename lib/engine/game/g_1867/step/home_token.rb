# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1867
      module Step
        class HomeToken < Engine::Step::HomeToken
          def override_entities
            @round.entities
          end

          def active_entities
            [entities[entity_index]]
          end
        end
      end
    end
  end
end
