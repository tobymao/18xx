# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1804
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def valid_buyer?
            buyer.corporation? && @game.stock_market
          end

          def buy_train_action(action)
            train = action.train
            seller = train.owner

            super # Perform the original buy train logic

            buyer = current_entity
            return unless buyer.corporation?
            return unless @game.stock_market

            # Move buyer's stock price UP (instead of right)
            @log << "#{buyer.name}'s stock price moves up for buying a train"
            @game.stock_market.move_up(buyer)

            # If the train was sold by another corporation, move their stock price down
            return unless seller.is_a?(Engine::Corporation)
            return unless seller != buyer

            @log << "#{seller.name}'s stock price moves down for selling a train"
            @game.stock_market.move_down(seller)
          end
        end
      end
    end
  end
end
