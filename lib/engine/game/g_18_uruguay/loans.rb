# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Loans
        def init_loans
          Array.new(self.class::NUMBER_OF_LOANS) { |id| Loan.new(id, self.class::LOAN_VALUE) }
        end

        def maximum_loans(entity)
          entity == @rptla ? self.class::NUMBER_OF_LOANS : entity.num_player_shares
        end

        def loans_due_interest(entity)
          entity.loans.size
        end

        def interest_owed(entity)
          return 0 if entity == @rptla

          10 * loans_due_interest(entity)
        end

        def interest_owed_for_loans(count)
          10 * count
        end

        def can_take_loan?(entity, ebuy: nil)
          # return false if nationalized?
          return false if entity == @rlpta
          return true if ebuy

          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            !@loans.empty?
        end

        def take_loan(entity, loan, ebuy: nil)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity, ebuy: ebuy)

          # raise GameError, "Not allowed to take loans after nationalization" if @game.nationalized?

          @bank.spend(loan.amount, entity)
          entity.loans << loan
          @rptla.loans << loan.dup
          @loans.delete(loan)
          @log << "#{entity.name} takes a loan and receives #{format_currency(loan.amount)}"
        end

        def payoff_loan(entity, number_of_loans, spender)
          total_amount = 0
          number_of_loans.times do |_i|
            paid_loan = entity.loans.pop
            amount = paid_loan.amount
            total_amount += amount
            spender.spend(amount, @bank)
          end
          @log << "#{spender.name} payoff #{number_of_loans} loan(s) for #{entity.name} and pays #{total_amount}"
        end

        def adjust_stock_market_loan_penalty(entity)
          delta = entity.loans.size - maximum_loans(entity)
          return unless delta.positive?

          delta.times do |_i|
            @stock_market.move_left(entity)
          end
        end

        def take_loan_if_needed_for_interest!(entity)
          owed = interest_owed(entity)
          return if owed.zero?

          remaining = owed - entity.cash
          perform_ebuy_loans(entity, remaining + 10) if remaining.positive?
        end

        def corps_pay_interest
          corps = @round.entities.select { |entity| entity.loans.size.positive? && entity != @rptla }
          corps.each do |corp|
            next if corp.closed?

            take_loan_if_needed_for_interest!(corp)
            pay_interest!(corp)
          end
        end
      end
    end
  end
end
