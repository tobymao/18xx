# frozen_string_literal: true

require_relative 'sell_company'
require_relative 'choose_power'

module Engine
  module Step
    module G18ZOO
      class FreeActionsOnSr < Engine::Step::Base
        include SellCompany
        include ChoosePower

        def actions(entity)
          return [] if @game.floated_corporation.nil?
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
          @game.floated_corporation
        end

        def blocking?
          active?
        end

        def process_pass(action)
          super

          @game.floated_corporation = nil
        end

        def ipo_type(_entity) end
      end
    end
  end
end
