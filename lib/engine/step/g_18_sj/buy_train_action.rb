# frozen_string_literal: true

module BuyTrainAction
  def buy_train_action(action, entity = nil)
    super

    @game.perform_nationalization if @game.pending_nationalization?

    return if !(exchange = action.exchange) || exchange.name == '4'

    @log << "The exchanged #{exchange.name} is removed from game"
    @depot.discarded.delete(exchange)
  end
end
