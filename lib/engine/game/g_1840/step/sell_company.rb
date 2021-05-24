# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1840
      module Step
        class SellCompany < Engine::Step::Base
          def actions(entity)
            if entity.company? && entity.owner &&
               (entity.owner == @game.owning_major_corporation(current_entity) || entity.owner == current_entity.owner)
              return ['choose_ability']
            end

            []
          end

          def blocks?
            false
          end

          def choices_ability(company)
            @game.sell_company_choice(company)
          end

          def process_choose_ability(action)
            company = action.entity
            @game.sell_company(company)
          end
        end
      end
    end
  end
end
