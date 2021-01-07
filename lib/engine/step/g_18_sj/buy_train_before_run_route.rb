# frozen_string_literal: true

require_relative '../buy_train'
require_relative 'buy_train_action'

module Engine
  module Step
    module G18SJ
      class BuyTrainBeforeRunRoute < BuyTrain
        include BuyTrainAction

        def actions(entity)
          return [] unless ability(entity)

          super
        end

        def round_state
          {
            premature_trains_bought: nil,
          }
        end

        def process_buy_train(action)
          from_depot = action.train.from_depot?
          buy_train_action(action)

          @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)
          @round.premature_trains_bought = action.entity

          pass! unless can_buy_train?(action.entity)
        end

        def help
          "Owning #{@game.motala_verkstad.name} gives the ability to buy trains before running any routes."
        end

        def pass!
          super

          ability(@game.current_entity)&.use! if @round.premature_trains_bought == @game.current_entity
        end

        def ability(entity)
          return if !@game.motala_verkstad || @game.motala_verkstad.owner != entity

          @game.abilities(@game.motala_verkstad, :train_buy)
        end
      end
    end
  end
end
