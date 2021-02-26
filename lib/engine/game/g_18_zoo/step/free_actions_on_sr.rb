# frozen_string_literal: true

require_relative 'sell_company'
require_relative 'choose_power'

module Engine
  module Game
    module G18ZOO
      module Step
        class FreeActionsOnSr < Engine::Step::Base
          include SellCompany
          include ChoosePower

          def actions(entity)
            return [] unless @round.floated_corporation
            return [] unless entity == current_entity && entity.player?

            actions = []
            actions << 'sell_company' if can_sell_any_companies?(entity)
            actions << 'choose' if choice_available?(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def description
            'Free actions'
          end

          def active?
            @round.floated_corporation
          end

          def log_pass(entity)
            actions = actions(entity)
            texts = []
            texts << 'selling companies' if actions.include?('sell_company')
            texts << 'using any power' if actions.include?('choose')
            @log << "#{entity.name} passes #{texts.join(' and ')}"
          end

          def process_pass(action)
            super

            @round.floated_corporation = nil
          end

          def ipo_type(_entity) end
        end
      end
    end
  end
end
