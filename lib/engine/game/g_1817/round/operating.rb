# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1817
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :cash_crisis_player
          attr_reader :paid_loans

          def setup
            @paid_loans = {}
            @game.payout_companies
            (@game.corporations + @game.minors + @game.companies).each(&:reset_ability_count_this_or!)
            after_setup
          end

          def after_process(action)
            # Keep track of last_player for Cash Crisis
            entity = @entities[@entity_index]
            @cash_crisis_player = entity.player
            pay_interest!(entity)

            if !active_step && entity == @current_operator && entity.trains.reject { |t| @game.pullman_train?(t) }.empty?
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
            return unless step_passed?(Engine::Step::BuyTrain)

            @paid_loans[entity] = true
            return if entity.loans.empty?

            bank = @game.bank
            return unless (owed = @game.pay_interest!(entity))

            owed_fmt = @game.format_currency(owed)

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
end
