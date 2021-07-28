# frozen_string_literal: true

module BuyTrainAction
  def buy_train_action(action, entity = nil)
    super

    do_after_buy_train_action(action, entity)

    @game.perform_nationalization if @game.pending_nationalization?

    return if !(exchange = action.exchange) || exchange.name == '4'

    @log << "The exchanged #{exchange.name} is removed from game"
    @game.remove_train(exchange)
  end
end
