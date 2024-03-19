# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18India
      module Step
        class Token < Engine::Step::Token
          # modified to prevent skipping step if there are token abilities
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity) || @game.abilities(entity, :token)

            ACTIONS
          end
        end
      end
    end
  end
end
