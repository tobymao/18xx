# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module GFrost1831
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def choices_ability(entity)
            return {} if !@game.use_influence?(entity) || !entity.owner&.player?

            @game.use_influence_choices(entity.owner)
          end

          def process_choose_ability(action)
            raise GameError, "#{action.choice} is not available" unless choices_ability(action.entity).include?(action.choice)

            @game.use_player_influence!(action.entity.owner, action.choice)
          end
        end
      end
    end
  end
end
