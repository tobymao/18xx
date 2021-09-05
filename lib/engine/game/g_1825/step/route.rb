# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1825
      module Step
        class Route < Engine::Step::Route
          LEASE_COST = 10

          def actions(entity)
            return [] if !entity.operator? || (entity.runnable_trains.empty? && !entity.receivership?)
            return [] unless @game.can_run_route?(entity)

            return ACTIONS + %w[special_buy] if entity.receivership? && !@round.leased_train

            ACTIONS
          end

          def setup
            @round.leased_train = nil
            super
          end

          def round_state
            super.merge(
              {
                leased_train: nil,
              }
            )
          end

          def help
            return super unless current_entity.receivership?

            loan_msg = if @round.receivership_loan.positive?
                         " #{current_entity.name} has spent #{@game.format_currency(@round.receivership_loan)} "\
                           'on track, tokens and/or a leased train that must be repaid out of the route '\
                           ' revenue. In the event that the revenue will not cover this cost, you must UNDO '\
                           'the moves that cannot be afforded.'
                       else
                         ''
                       end

            "#{current_entity.name} is in receivership (it has no president). "\
              "#{@game.acting_for_entity(current_entity).name} has been selected to run its trains."\
              "#{loan_msg}"
          end

          def process_run_routes(action)
            revenue = @game.routes_revenue(action.routes)

            if revenue < @round.receivership_loan
              raise GameError, "Revenue of #{revenue} insufficent to cover #{@round.receivership_loan} in costs"
            end

            super
          end

          def buyable_items(entity)
            return [] unless entity.receivership?
            return [] if @round.leased_train

            train = @game.depot.upcoming.first
            [Item.new(description: "Lease #{train.name} train from bank", cost: LEASE_COST)]
          end

          def process_special_buy(action)
            train = @game.depot.upcoming.first
            entity = action.entity
            @round.leased_train = train

            if entity.cash >= LEASE_COST
              entity.spend(LEASE_COST, @game.bank)
            else
              diff = LEASE_COST - entity.cash
              entity.spend(entity.cash, @game.bank) if entity.cash.positive?
              @round.receivership_loan += diff
            end
            @log << "#{entity.name} leases #{train.name} for #{@game.format_currency(LEASE_COST)}"
          end
        end
      end
    end
  end
end
