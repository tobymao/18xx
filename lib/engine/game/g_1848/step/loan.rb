# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'skip_boe'

module Engine
  module Game
    module G1848
      module Step
        class Loan < Engine::Step::Base
          include SkipBoe

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if @loan_taken
            return [] if entity == @game.boe

            actions = []
            actions << 'take_loan' if @game.can_take_loan?(entity)
            actions << 'pass' if blocks?

            actions
          end

          def description
            'Take Loans'
          end

          def pass_description
            'Skip (Loans)'
          end

          def blocks?
            @opts[:blocks] && @game.can_take_loan?(current_entity)
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
