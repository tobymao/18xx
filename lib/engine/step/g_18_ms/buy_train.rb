# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18MS
      class BuyTrain < BuyTrain
        def process_buy_train(action)
          entity ||= action.entity
          price = action.price
          train = action.train
          player = entity.player

          president_assist, fee_amount = @game.president_assisted_buy(entity, train, price)

          if president_assist.positive?
            player.spend(president_assist + fee_amount, @game.bank)
            @game.bank.spend(president_assist, entity)
            assist = @game.format_currency(president_assist).to_s
            fee = @game.format_currency(fee_amount).to_s
            @log << "#{player.name} pays #{assist} and an additional #{fee} fee to assist buying a #{train.name} train"
          end

          emergency_buy_with_loan = false

          if train == @depot.min_depot_train &&
            price > entity.cash + player.cash &&
            must_buy_train?(entity) &&
            @game.liquidity(player, emergency: true) == player.cash # Nothing more to sell

            # Prepare to take a loan
            emergency_buy_with_loan = true
            corporation_cash = entity.cash
            player_cash = player.cash
            player_cash = 0 if player_cash.negative?
            # Add temporary money in the corporation to pay for the train
            @game.bank.spend(price, entity)
          end

          super

          return unless emergency_buy_with_loan

          # Corporation should have no money left
          entity.spend(entity.cash, @game.bank)

          # The player borrows the missing amount, and add a $50 interest
          debt = price - corporation_cash - player_cash
          interest = 50
          player.spend(player_cash + debt + interest, @game.bank, check_cash: false)
          @log << "#{player.name} has to borrow #{@game.format_currency(debt)} to pay for the train"
          @log << "An extra #{@game.format_currency(interest)} is added to the debt"
          pass!
        end
      end
    end
  end
end
