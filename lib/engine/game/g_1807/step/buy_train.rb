# frozen_string_literal: true

require_relative '../../g_1867/step/buy_train'

module Engine
  module Game
    module G1807
      module Step
        class BuyTrain < G1867::Step::BuyTrain
          def pass!
            super
            return unless current_entity.trains.empty?

            @game.log << "#{current_entity.name} does not own a train"
            old_price = current_entity.share_price
            @game.stock_market.move_left(current_entity)
            @game.log_share_price(current_entity, old_price)
          end
        end
      end
    end
  end
end
