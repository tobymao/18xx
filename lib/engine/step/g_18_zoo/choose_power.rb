# frozen_string_literal: true

module Engine
  module Step
    module ChoosePower
      def choice_name
        'Use powers'
      end

      def choices
        entity = current_entity
        @choices = Hash.new { |h, k| h[k] = [] }
        @choices['midas'] = 'Midas' if company_midas?(entity)
        @choices['holiday'] = 'Holiday' if company_holiday?(entity)
        @choices['greek_to_me'] = 'It’s all greek to me' if company_greek_to_me?(entity)
        @choices['whatsup'] = 'Whatsup' if company_whatsup?(entity)
        @choices
      end

      def choice_available?(entity)
        company_midas?(entity) || company_holiday?(entity) || company_whatsup?(entity) ||
          company_greek_to_me?(entity)
      end

      def company_midas?(entity)
        entity&.player? && entity.companies.any? { |c| c.sym == :MIDAS }
      end

      def company_holiday?(entity)
        entity&.player? && entity.companies.any? { |c| c.sym == :HOLIDAY }
      end

      def company_whatsup?(entity)
        entity&.player? && entity.companies.any? { |c| c.sym == :WHATSUP }
      end

      def company_greek_to_me?(entity)
        entity&.player? && entity.companies.any? { |c| c.sym == :IT_S_ALL_GREEK_TO_ME }
      end

      def process_choose(action)
        raise GameError, 'Power not yet implemented' if action.choice == 'midas'
        raise GameError, 'Power not yet implemented' if action.choice == 'holiday'
        raise GameError, 'Power not yet implemented' if action.choice == 'greek_to_me'
        raise GameError, 'Power not yet implemented' if action.choice == 'whatsup'
      end
    end
  end
end
