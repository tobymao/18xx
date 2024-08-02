# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Uruguay
      module Step
        class TakeLoanBuyCompany < Engine::Step::BuyCompany
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity == @game.rptla
            return [] unless can_buy_company?(entity)

            actions = []
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@round.loan_taken && !@game.nationalized?
            actions << 'buy_company' if can_buy_company?(entity)
            actions << 'pass' if can_buy_company?(entity) || (@game.can_take_loan?(entity) && !@round.loan_taken)

            actions
          end

          def log_skip(entity)
            return if entity.minor?
            return if @game.nationalized?
            return if entity.corporation == @game.rptla

            super
          end

          def can_buy_company?(entity)
            companies = @game.purchasable_companies(entity)

            entity == current_entity &&
              @game.phase.status.include?('can_buy_companies') &&
              companies.any? &&
              companies.map(&:min_price).min <= buying_power(entity)
          end

          def description
            'Take Loans or Buy Company'
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
