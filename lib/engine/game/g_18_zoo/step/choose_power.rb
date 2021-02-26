# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module ChoosePower
        def choice_name
          'Use powers'
        end

        def choices
          entity = current_entity
          @choices = {}
          @choices[:midas] = 'Midas' if company_midas?(entity)
          @choices[:holiday] = 'Holiday' if company_holiday?(entity)
          @choices[:greek_to_me] = 'It’s all greek to me' if company_greek?(entity)
          @choices[:whatsup] = 'Whatsup' if company_whatsup?(entity)
          @choices
        end

        def choice_available?(entity)
          company_midas?(entity) || company_holiday?(entity) || company_whatsup?(entity) || company_greek?(entity)
        end

        def company_midas?(entity)
          entity&.companies&.include?(@game.midas) &&
            @game.midas.all_abilities.none? { |ability| ability.is_a?(Engine::Ability::Close) }
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

        def process_choose(action)
          raise GameError, 'Power not yet implemented' if action.choice == 'holiday'
          raise GameError, 'Power not yet implemented' if action.choice == 'greek_to_me'
          raise GameError, 'Power not yet implemented' if action.choice == 'whatsup'

          if action.choice == 'midas'
            @game.midas.add_ability(Engine::Ability::Close.new(type: 'close'))
            @log << "#{current_entity.name} uses \"Midas\", will get the Priority for the next SR"
          end
        end
      end
    end
  end
end
