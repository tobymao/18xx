# frozen_string_literal: true

module Engine
  module Step
    module G18ZOO
      module ChoosePower
        def choice_name
          'Use powers'
        end

        def choices
          entity = current_entity
          @choices = {}
          @choices[:midas] = true if company_midas?(entity)
          @choices[:holiday] = true if company_holiday?(entity)
          @choices[:greek_to_me] = true if company_greek?(entity)
          @choices[:whatsup] = true if company_whatsup?(entity)
          @choices
        end

        def choice_available?(entity)
          company_midas?(entity) || company_holiday?(entity) || company_whatsup?(entity) || company_greek?(entity)
        end

        def company_midas?(entity)
          entity&.companies&.include?(@game.midas)
        end

        def company_holiday?(entity)
          entity&.companies&.include?(@game.holiday)
        end

        def company_whatsup?(entity)
          entity&.companies&.include?(@game.whatsup)
        end

        def company_greek?(entity)
          entity&.companies&.include?(@game.it_s_all_greek_to_me)
        end

        def process_choose(_action)
          raise GameError, 'Power not yet implemented'
        end
      end
    end
  end
end
