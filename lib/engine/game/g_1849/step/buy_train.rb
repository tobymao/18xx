# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1849
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          attr_accessor :e_token

          def setup
            super
          end

          def pass!
            super
            @game.reorder_corps if @moved_any
            @moved_any = false
          end

          def process_sell_shares(action)
            price_before = action.bundle.shares.first.price
            super
            return unless price_before != action.bundle.shares.first.price

            @game.moved_this_turn << action.bundle.corporation
            @moved_any = true
          end

          def can_sell?(entity, bundle)
            # Corporation must complete its first operating round before its shares can be sold
            corporation = bundle.corporation
            return false unless corporation.operated?
            return false if @round.current_operator == corporation && corporation.operating_history.size < 2

            super
          end

          def buyable_trains(entity)
            # Cannot buy E-train without E-token
            trains_to_buy = super

            trains_to_buy = trains_to_buy.reject { |t| t.name == 'E' }
            trains_to_buy << e_train if @game.electric_dreams? && can_buy_e?(entity)
            trains_to_buy.uniq
          end

          def e_train
            @depot.depot_trains.find { |t| t.name == 'E' }
          end

          def can_buy_e?(entity)
            entity.e_token == true &&
              e_train.price <= entity.cash
          end

          # once the game is merged into the site, the check_for_cheapest_train method can be modified in train.rb to
          # accept two arguments (train, entity). Then, it can be updated in the buy_train_action method and anywhere
          # else it appears on the site, and the buy_train_action can be removed from this file.

          def check_for_cheapest_train(train, entity)
            cheapest = @depot.send(@game.electric_dreams? && !entity.e_token ? :min_depot_train_no_e_token : :min_depot_train)
            cheapest_names = names_of_cheapest_variants(cheapest)
            raise GameError, "Cannot purchase #{train.name} train: cheaper train available (#{cheapest_names.first})" if
              !cheapest_names.include?(train.name) &&
              @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST &&
              (!@game.class::EBUY_OTHER_VALUE || train.from_depot?)
          end

          def buy_train_action(action, entity = nil, borrow_from: nil)
            entity ||= action.entity
            train = action.train
            train.variant = action.variant
            price = action.price
            exchange = action.exchange

            # Check if the train is actually buyable in the current situation
            raise GameError, 'Not a buyable train' unless buyable_exchangeable_train_variants(train, entity,
                                                                                              exchange).include?(train.variant)
            raise GameError, 'Must pay face value' if must_pay_face_value?(train, entity, price)
            raise GameError, 'An entity cannot buy a train from itself' if train.owner == entity

            remaining = price - buying_power(entity)
            if remaining.positive? && president_may_contribute?(entity, action.shell)
              check_for_cheapest_train(train, entity)

              raise GameError, 'Cannot contribute funds when exchanging' if exchange
              raise GameError, 'Cannot buy for more than cost' if price > train.price

              try_take_player_loan(entity.owner, remaining)

              player = entity.owner

              if borrow_from && player.cash < remaining
                current_cash = player.cash
                extra_needed = remaining - current_cash
                player.spend(current_cash, entity)
                @log << "#{player.name} contributes #{@game.format_currency(current_cash)}"
                borrow_from.spend(extra_needed, entity)
                @log << "#{borrow_from.name} contributes #{@game.format_currency(extra_needed)}"
              else
                player.spend(remaining, entity)
                @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
              end
            end

            try_take_loan(entity, price)

            if exchange
              verb = "exchanges a #{exchange.name} for"
              @depot.reclaim_train(exchange)
            else
              verb = 'buys'
            end

            source = train.owner
            source_name = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name

            @log << "#{entity.name} #{verb} a #{train.name} train for "\
                    "#{@game.format_currency(price)} from #{source_name}"

            @game.buy_train(entity, train, price)
            @game.phase.buying_train!(entity, train, source)
            pass! if !can_buy_train?(entity) && pass_if_cannot_buy_train?(entity)
          end
        end
      end
    end
  end
end
