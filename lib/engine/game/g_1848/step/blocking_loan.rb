# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'skip_boe'

module Engine
  module Game
    module G1848
      module Step
        class BlockingLoan < Engine::Step::Base
          include SkipBoe
          # Used when a company is one step away from receivership & places a token.
          # Should be able to take a loan before receivership
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity == @game.boe

            actions = []
            actions += %w[take_loan pass] if check_blocking_loan(entity)
            actions
          end

          def check_blocking_loan(entity)
            @game.can_take_loan?(entity) && !@round.loan_taken && @game.first_column?(entity) && entity.trains.empty?
          end

          def description
            'Take Loans'
          end

          def blocks?
            true
          end

          def process_take_loan(action)
            entity = action.entity
            @game.take_loan(entity, action.loan)
            @round.loan_taken = true
          end

          def round_state
            super.merge({
                          # has player taken a loan this or already
                          loan_taken: false,
                        })
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
