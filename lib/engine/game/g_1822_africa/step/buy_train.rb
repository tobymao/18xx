# frozen_string_literal: true

require_relative '../../g_1822/step/buy_train'

module Engine
  module Game
    module G1822Africa
      module Step
        class BuyTrain < G1822::Step::BuyTrain
          def actions(entity)
            actions = super

            actions << 'choose_ability' if !choices_ability(entity).empty? && !actions.include?('choose_ability')

            actions
          end

          def choices_ability(entity)
            return {} unless entity.company?

            @game.company_choices(entity, :buy_train)
          end

          def process_choose_ability(action)
            @game.company_made_choice(action.entity, action.choice, :buy_train)
          end
        end
      end
    end
  end
end
