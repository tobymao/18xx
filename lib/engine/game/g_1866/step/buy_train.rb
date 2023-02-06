# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1866
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            actions = super
            if !actions.empty? && entity.operator? && @game.trains_empty?(entity) && @game.can_take_loan?(entity) &&
              entity.cash < @game.depot.min_depot_price
              actions << 'take_loan'
            end
            actions
          end

          def buyable_trains(entity)
            # Can't buy trains from other corporations if the operating corporation took a loan this turn
            return reject_infrastructure_train(super) if !@took_loan && @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end

          def can_sell?(entity, bundle)
            return true if entity == bundle.corporation

            false
          end

          def log_skip(entity)
            return if @game.national_corporation?(entity)

            @log << "#{entity.name} skips buy trains"
          end

          def process_buy_train(action)
            entity = action.entity
            price = action.price
            train = action.train
            train.variant = action.variant
            remaining = price - entity.cash
            if remaining.positive? && @game.can_take_loan?(entity) && @game.trains_empty?(entity)
              check_for_cheapest_train(train)

              raise GameError, "#{entity.owner.name} cannot contribute funds as long as #{entity.name} can take loans"
            end

            super
            @took_loan = false
          end

          def process_sell_shares(action)
            super

            entity = action.entity
            @game.player_sold_shares[entity.owner][entity] = true
          end

          def process_take_loan(action)
            @game.take_loan(action.entity, action.loan)
            @took_loan = true
          end

          def room?(entity, _shell = nil)
            entity.trains.count { |t| !t.obsolete && !@game.infrastructure_train?(t) } < @game.train_limit(entity)
          end

          def setup
            super
            @took_loan = false
          end

          def try_take_player_loan(entity, cost)
            return unless cost.positive?
            return unless cost > entity.cash

            difference = cost - entity.cash
            @game.take_player_loan(entity, difference)
            @log << "#{entity.name} takes a loan of #{@game.format_currency(difference)} with "\
                    "#{@game.format_currency(@game.player_loan_interest(difference))} in interest"
          end

          def reject_infrastructure_train(trains)
            trains.reject { |t| @game.infrastructure_train?(t) }
          end
        end
      end
    end
  end
end
