# frozen_string_literal: true

require_relative '../operating'
require_relative '../../step/buy_train'

module Engine
  module Round
    module G1817
      class Operating < Operating
        attr_accessor :cash_crisis_player
        attr_reader :paid_loans

        def setup
          @paid_loans = {}
        end

        def select_entities
          super.reject { |c| c.share_price.liquidation? }
        end

        def after_process(action)
          # Keep track of last_player for Cash Crisis
          entity = @entities[@entity_index]
          @cash_crisis_player = entity.player
          pay_interest!(entity)

          if !active_step && entity.operator? && entity.trains.empty?
            @log << "#{entity.name} has no trains and liquidates"
            @game.liquidate!(entity)
          end

          super
        end

        def start_operating
          entity = @entities[@entity_index]
          if entity.share_price.liquidation?
            # Skip entities that have gone into liquidation due to bankrupcy.
            next_entity!
          else
            super
          end
        end

        def pay_interest!(entity)
          @cash_crisis_due_to_interest = nil
          return if @paid_loans[entity]
          return unless @steps.any? { |step| step.passed? && step.is_a?(Step::BuyTrain) }

          @paid_loans[entity] = true
          return if entity.loans.empty?

          bank = @game.bank
          owed = @game.interest_owed(entity)
          owed_fmt = @game.format_currency(owed)

          while owed > entity.cash &&
              (loan = @game.loans[0]) &&
              entity.loans.size < @game.maximum_loans(entity)
            @game.take_loan(entity, loan)
          end

          if owed <= entity.cash
            @log << "#{entity.name} pays #{owed_fmt} interest for #{entity.loans.size} loans"
            entity.spend(owed, bank)
            return
          end

          owner = entity.owner
          @game.liquidate!(entity)
          transferred = ''

          if entity.cash.positive?
            transferred = ", transferring #{@game.format_currency(entity.cash)} to #{owner.name}"
            entity.spend(entity.cash, owner)
          end

          @log << "#{entity.name} cannot afford #{owed_fmt} interest and goes into liquidation#{transferred}"

          owner.spend(owed, bank, check_cash: false)
          @cash_crisis_due_to_interest = entity
          @log << "#{owner.name} pays #{owed_fmt} interest for #{entity.loans.size} loans"
        end
      end
    end
  end
end
