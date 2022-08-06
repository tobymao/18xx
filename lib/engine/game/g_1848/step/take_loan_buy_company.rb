# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'skip_boe'

module Engine
  module Game
    module G1848
      module Step
        class TakeLoanBuyCompany < Engine::Step::BuyCompany
          include SkipBoe

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity == @game.boe

            actions = []
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@round.loan_taken
            actions << 'buy_company' if can_buy_company?(entity)
            actions << 'pass' if blocks?

            actions
          end

          def description
            'Take Loans or Buy Company'
          end

          def blocks?
            @opts[:blocks] && (@game.can_take_loan?(current_entity) || can_buy_company?(current_entity))
          end

          def process_take_loan(action)
            entity = action.entity
            @game.take_loan(entity, action.loan)
            @round.loan_taken = true
          end

          def round_state
            {
              # has player taken a loan this or already
              loan_taken: false,
            }
          end

          def setup
            # you can only take one loan per OR turn
            @round.loan_taken = false
          end
        end
      end
    end
  end
end
