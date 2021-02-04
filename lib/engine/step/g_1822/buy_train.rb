# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_train'

module Engine
  module Step
    module G1822
      class BuyTrain < BuyTrain
        def buyable_trains(entity)
          # Cannot buy trains from other corporations in phase 1 and 2
          return super if @game.phase.status.include?('can_buy_trains')

          super.select(&:from_depot?)
        end

        def process_buy_train(action)
          check_spend(action)
          if action.exchange
            upgrade_train_action(action)
          else
            buy_train_action(action)
          end
          pass! unless can_buy_train?(action.entity)

          # Special case when we are in phase 1, and first 2 train is bought or upgraded
          return if @game.phase.name.to_i > 1 || action.train.name != '2'

          # Clone the train that is bought, the phase change logic checks the train.sym. This is still the
          # base train's sym and not the variant's sym. Cant change in buying_train! since other games relay on
          # the base sym to change phase or rust trains
          train = action.train
          train_check = Engine::Train.new(name: train.name, distance: train.distance, price: train.price)
          @game.phase.buying_train!(action.entity, train_check)
        end

        private

        def upgrade_train_action(action)
          entity = action.entity
          train = action.train
          price = action.price

          # Convert the L train to the 2 train
          train.variant = action.variant

          # Spend the money from the player
          entity.spend(price, @game.bank)

          @log << "#{entity.name} upgrades a L train to a 2 train for #{@game.format_currency(price)}"
        end
      end
    end
  end
end
