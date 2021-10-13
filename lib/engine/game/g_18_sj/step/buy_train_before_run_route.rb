# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative 'buy_train_action'

module Engine
  module Game
    module G18SJ
      module Step
        class BuyTrainBeforeRunRoute < Engine::Step::BuyTrain
          include BuyTrainAction

          def actions(entity)
            ability(entity) && can_buy_train?(entity) ? %w[buy_train pass] : []
          end

          def round_state
            {
              premature_trains_bought: [],
            }
          end

          def process_buy_train(action)
            from_depot = action.train.from_depot?
            buy_train_action(action)

            @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)
            @round.premature_trains_bought << action.entity

            pass! unless can_buy_train?(action.entity)
          end

          def help
            "Owning #{@game.motala_verkstad.name} gives the ability to buy trains before running any routes."
          end

          def ability(entity)
            return if !@game.motala_verkstad || entity.minor? || @game.motala_verkstad.owner != entity

            @game.abilities(@game.motala_verkstad, :train_buy)
          end

          def do_after_buy_train_action(action, _entity)
            # Trains bought with this ability can be run even if they have already run this OR
            action.train.operated = false
          end
        end
      end
    end
  end
end
