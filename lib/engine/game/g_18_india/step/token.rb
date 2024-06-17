# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18India
      module Step
        class Token < Engine::Step::Token
          # modified to prevent skipping step if there are token abilities
          def can_place_token?(entity)
            super || @game.abilities(entity, :token)
          end
        end
      end
    end
  end
end
