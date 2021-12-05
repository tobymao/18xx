# frozen_string_literal: true

require_relative 'base'
require_relative '../item'

module Engine
  module Step
    class SpecialChoose < Engine::Step::Base
      ACTIONS = %w[choose_ability].freeze

      def actions(entity)
        return [] unless entity.company?
        choose = entity.all_abilities.find { |a| a.type == :choose }
        return [] unless choose

        ACTIONS
      end

      def choice_name
        return "Choose for #{current_entity.name}"

        'Choose'
      end

      def blocks?
        false
      end

      def choices_ability
        choose_ability = current_entity.all_abilities.find { |a| a.type == :choose }
        choose_ability.choices
      end

      def description
        'Choose'
      end

      def process_choose_ability(action)
        raise NotImplementedError
      end

      def skip!
        pass!
      end

    end
  end
end
