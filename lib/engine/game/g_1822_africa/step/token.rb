# frozen_string_literal: true

require_relative '../../g_1822/step/token'

module Engine
  module Game
    module G1822Africa
      module Step
        class Token < G1822::Step::Token
          def actions(entity)
            actions = super.dup

            actions << 'choose_ability' if need_choose_ability?(entity, actions) && !actions.include?('choose_ability')

            actions << 'pass' if !actions.empty? && !actions.include?('pass')
            actions
          end

          def need_choose_ability?(entity, actions)
            return true if choices_ability(entity).any?
            return false unless actions.empty?

            ability_chpr_lcdr?(entity) || ability_gold_mine?(entity)
          end

          def ability_gold_mine?(entity)
            return unless entity.corporation?

            entity.companies.any? { |c| c.id == @game.class::COMPANY_GOLD_MINE }
          end
        end
      end
    end
  end
end
