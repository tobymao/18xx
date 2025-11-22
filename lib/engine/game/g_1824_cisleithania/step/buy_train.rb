# frozen_string_literal: true

require_relative '../../g_1824/step/buy_train'

module Engine
  module Game
    module G1824Cisleithania
      module Step
        class BuyTrain < G1824::Step::BuyTrain
          def must_buy_train?(entity)
            # Rule X.3 and X.4: Construction railways cannot own any trains
            return false if @game.construction_railway?(entity) || @game.bond_railway?(entity)

            super
          end

          def can_entity_buy_train?(entity)
            # Rule X.3 and X.4: Construction railways cannot buy any trains
            return false if @game.construction_railway?(entity) || @game.bond_railway?(entity)

            entity.operator?
          end

          def process_buy_train(action)
            super

            return unless @game.two_player?

            # Rule X.4, need to handle extra tokening of bond railway
            entity ||= action.entity
            train = action.train
            @game.set_last_train_buyer(entity, train) if train.name == '4' && @depot.depot_trains.first.name == '5'
            @game.set_last_train_buyer(entity, train) if train.name == '5' && @depot.depot_trains.first.name == '6'
          end
        end
      end
    end
  end
end
