# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1824
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership?

            super
          end

          def can_entity_buy_train?(_entity)
            true
          end

          def process_buy_train(action)
            entity ||= action.entity
            train = action.train

            if entity&.corporation? && !@game.g_train?(train) && @game.coal_railway?(entity)
              raise GameError, 'Coal railways can only own g-trains'
            end

            super

            if (exchange = action.exchange)
              @log << "The exchanged #{exchange.name} train is removed from game"
              @game.remove_train(exchange)
            end

            @game.post_train_buy(train)
          end

          def buyable_trains(entity)
            trains = super
            is_coal_company = @game.coal_railway?(entity)

            # Coal railways may only buy g-trains, other corporations may buy any
            trains.reject! { |t| is_coal_company && !@game.g_train?(t) }

            # Cannot buy g-trains until first 2 train has been bought
            trains.reject! { |t| @game.g_train?(t) && !@game.two_train_bought }

            trains.select!(&:from_depot?) unless @game.phase.status.include?('can_buy_trains')

            trains
          end

          def must_take_loan?(corporation)
            price = cheapest_train_price(corporation)
            (@game.buying_power(corporation) + corporation.owner.cash) < price
          end

          def cheapest_train_price(corporation)
            cheapest_train = buyable_trains(corporation).min_by(&:price)
            puts "Cheapest train: #{cheapest_train}"
            cheapest_train.price
          end

          def try_take_player_loan(entity, cost)
            return unless cost.positive?
            return unless cost > entity.cash

            difference = cost - entity.cash

            @game.increase_debt(entity, difference)

            @log << "#{entity.name} takes a debt of #{@game.format_currency(difference)}"

            @game.bank.spend(difference, entity)
          end
        end
      end
    end
  end
end
