# frozen_string_literal: true

require_relative '../../g_1817/step/buy_train'

module Engine
  module Game
    module G18USA
      module Step
        class BuyTrain < G1817::Step::BuyTrain
          def pass_if_cannot_buy_train?(_entity)
            super && !@game.pending_rusting_event
          end

          def should_buy_train?(entity)
            :liquidation if entity.trains.reject { |t| @game.pullman_train?(t) }.empty?
          end

          def buyable_trains(entity)
            buyable_trains = super
            # Cannot buy a pullman if you have a pullman
            buyable_trains.reject! { |t| @game.pullman_train?(t) } if entity.trains&.any? { |t| @game.pullman_train?(t) }
            buyable_trains
          end
        end
      end
    end
  end
end
