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

          super
        end
      end
    end
  end
end
