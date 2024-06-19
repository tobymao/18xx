# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/train'

module Engine
  module Game
    module G18India
      module Step
        class SellBuyTrain < Engine::Step::BuyTrain
          include Engine::Step::Train

          # Allow the sales of train
          def actions(entity)
            return [] if entity != current_entity

            actions = []
            actions << 'buy_train' if can_buy_train?(entity)
            actions << 'sell_train' if can_sell_train?(entity)
            actions << 'pass' unless actions.empty?

            actions
          end

          def description
            'Sell and Buy Trains'
          end

          def setup
            @round.trains_brought = []
            super
          end

          def round_state
            {
              trains_brought: [],
            }
          end

          # ----- sell train methods -----

          def can_sell_train?(entity)
            !sellable_trains(entity).empty?
          end

          # can't sell trains that have been just purchased from the Depot
          def sellable_trains(entity)
            trains = entity.trains.reject { |t| t.salvage.zero? } || [] # May not sell the 4x3 to bank
            trains - @round.trains_brought
          end

          def train_sale_price(train)
            train.salvage
          end

          def process_sell_train(action)
            operator = action.entity
            train = action.train
            price = action.price
            @game.sell_train(operator, train, price)
            @log << "#{operator.name} sells #{train.name} to the Bank for #{@game.format_currency(price)}"
          end

          # ----- modified BuyTrains methods -----

          def process_buy_train(action)
            train = action.train
            source = train.owner
            # track trains purchased from the Depot
            @round.trains_brought << action.train if source == @depot
            raise GameError, 'Cannot buy a 2nd phase IV train' if buying_another_phase_iv_train?(action.entity, train)

            super
          end

          def buying_another_phase_iv_train?(operator, train)
            return false unless operator&.operator?

            own_a_phase_iv = operator.trains.any? { |t| t.available_on == "III'" }
            own_a_phase_iv && train.available_on == "III'"
          end

          # modified from Step::Train to prevent automatic passing after buying
          def pass_if_cannot_buy_train?(_entity)
            false
          end
        end
      end
    end
  end
end
