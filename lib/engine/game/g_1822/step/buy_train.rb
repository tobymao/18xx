# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1822
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            # Can't buy trains from other corporations in phase 1 and 2
            return super if @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end

          def process_buy_train(action)
            check_spend(action)
            if action.exchange
              upgrade_train_action(action)
            else
              check_e_train(action)
              buy_train_action(action)
            end
            pass! unless can_buy_train?(action.entity)

            # Special case when we are in phase 1, and first 2 train is bought or upgraded
            return if @game.phase.name.to_i > 1 || action.train.name != '2'

            # Clone the train that is bought, the phase change logic checks the train.sym. This is still the
            # base train's sym and not the variant's sym. Cant change in buying_train! since other games relay on
            # the base sym to change phase or rust trains
            train = action.train
            train_check = Engine::Train.new(name: train.name, distance: train.distance, price: train.price)
            @game.phase.buying_train!(action.entity, train_check, train.owner)
          end

          def room?(entity, _shell = nil)
            entity.trains.count { |t| !@game.extra_train?(t) } < @game.train_limit(entity)
          end

          def try_take_player_loan(entity, cost)
            return unless cost.positive?
            return unless cost > entity.cash

            raise GameError, "#{entity.name} still need to sell shares before a loan can be granted" if sellable_shares?(entity)

            difference = cost - entity.cash
            @game.take_player_loan(entity, difference)
            @log << "#{entity.name} takes a loan of #{@game.format_currency(difference)} with "\
                    "#{@game.format_currency(@game.player_loan_interest(difference))} in interest"
          end

          def check_e_train(action)
            return if !action.variant || (action.variant && action.variant != @game.class::E_TRAIN)

            corporation = action.entity
            return if corporation.trains.none? { |t| t.name == @game.class::E_TRAIN }

            raise GameError, "#{corporation.id} can only own one E-train"
          end

          def must_take_player_loan?(entity)
            # Must sell all shares before a loan can be granted
            return false if sellable_shares?(entity.owner)

            funds_required = @game.depot.min_depot_price - @game.total_emr_buying_power(entity.owner, entity)
            funds_required.positive?
          end

          def sellable_shares?(player)
            (@game.liquidity(player, emergency: true) - player.cash).positive?
          end

          def upgrade_train_action(action)
            entity = action.entity
            train = action.train
            price = action.price

            # Convert the L train to the 2 train
            train.variant = action.variant

            # Spend the money from the player
            entity.spend(price, @game.bank)

            @log << "#{entity.name} upgrades a L train to a 2 train for #{@game.format_currency(price)}"
          end
        end
      end
    end
  end
end
