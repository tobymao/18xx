# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Token < Engine::Step::Token
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            super
          end

          private

          def can_choose_ability?(company)
            entity = @game.current_entity
            return false if entity.player?

            # p "Token.can_choose_ability?(#{company.name})" # TODO: use for debug
            return true if can_choose_ability_on_any_step(entity, company)

            false
          end
        end
      end
    end
  end
end
