# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1824
      class Loan < Base
        def actions(entity)
          return [] if !entity.corporation? ||
            entity != current_entity ||
            !@game.emergency?(entity) ||
            !@game.head_loan.positive?

          ['take_loan']
        end

        def description
          'Take Loan'
        end

        def process_take_loan(action)
          entity = action.entity
          @game.take_loan(entity, action.loan)
        end
      end
    end
  end
end
