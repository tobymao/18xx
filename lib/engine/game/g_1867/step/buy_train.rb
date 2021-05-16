# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G1867
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include Engine::Step::AutomaticLoan

          def actions(entity)
            return [] if entity != current_entity
            return %w[buy_train] if must_buy_train?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def available_cash(_player)
            current_entity.buying_power
          end

          def pass!
            super
            @game.nationalize!(current_entity) if current_entity.trains.empty?
          end

          def discountable_trains_allowed?(_entity)
            @game.phase.name.to_i == 8
          end

          def can_sell?(_entity, _bundle)
            # Players cannot sell shares in EMR for 1867
            false
          end

          def must_buy_train?(entity)
            # Can afford one by taking out max loans
            super && @game.buying_power(entity, full: true) >= needed_cash(entity)
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def ebuy_president_can_contribute?(_corporation)
            false
          end

          def buy_train_action(action, entity = nil)
            @depot_train = action.train.from_depot?
            super
            @game.post_train_buy
          end

          def buying_power(entity)
            if must_buy_train?(entity)
              @game.buying_power(entity, full: true)
            else
              @game.buying_power(entity)
            end
          end

          def needed_cash(_entity)
            @depot.min_depot_price
          end

          def try_take_loan(entity, cost)
            if must_buy_train?(entity) && @depot_train
              super
            elsif cost > entity.cash
              reason =
                if must_buy_train?(entity)
                  'as train is not from depot'
                elsif @game.buying_power(entity, full: true) <= needed_cash(entity)
                  'cannot take enough loans to purchase'
                else
                  'as do not need to buy'
                end
              raise GameError, "Not able to take loan to purchase at #{@game.format_currency(cost)}, " + reason
            end
          end
        end
      end
    end
  end
end
