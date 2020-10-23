# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1817
      class PostConversionLoans < Base
        def actions(entity)
          return [] if entity != @round.converted

          actions = []
          actions << 'take_loan' if @game.can_take_loan?(entity)
          actions << 'pass' if actions.any?
          actions
        end

        def process_take_loan(action)
          corporation = action.entity
          @game.take_loan(corporation, action.loan)
        end

        def pass_description
          if @round.needs_money?(current_entity)
            'Liquidate Corporation'
          elsif current_actions.include?('take_loan')
            'Pass (Loans)'
          else
            super
          end
        end

        def description
          if @round.needs_money?(current_entity)
            'Taking Loans for tokens'
          else
            'Taking Loans'
          end
        end

        def corporation
          @round.converted
        end

        def active?
          corporation && super
        end

        def active_entities
          return [] unless @game.can_take_loan?(corporation)

          [@round.converted]
        end
      end
    end
  end
end
