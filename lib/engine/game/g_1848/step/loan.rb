# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1848
      module Step
        class Loan < Engine::Step::Base
          ACTIONS = ['take_loan'].freeze
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if @loan_taken || !@game.can_take_loan?(entity)

            ACTIONS
          end

          def description
            'Take Loans'
          end

          def blocks?
            false
          end

          def process_take_loan(action)
            @loan_taken = true
            entity = action.entity
            @game.take_loan(entity, action.loan)
          end

          def setup
            # you can only take one loan per OR turn
            @loan_taken = false
          end
        end
      end
    end
  end
end
