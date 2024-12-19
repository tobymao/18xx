# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def room?(entity)
            room = @game.num_corp_trains(entity) < @game.train_limit(entity)
            return true if room

            return false unless (upcoming_train = @game.depot.upcoming[0])
            # even when train tight, there's room for a self-rust
            return true if entity.trains.any? { |t| t.rusts_on == upcoming_train.name }
          end

          def check_connected!(buyer, train)
            return if train.owner == @game.depot

            seller = train.corporation
            seller_nodes = @game.graph.connected_nodes(seller)
            return if @game.graph.connected_nodes(buyer).any? { |node, _| seller_nodes.include?(node) }

            raise GameError, "#{buyer.name} must be connected to #{seller.name} to buy their train."
          end

          def process_buy_train(action)
            check_connected!(action.entity, action.train)
            super
          end
        end
      end
    end
  end
end
