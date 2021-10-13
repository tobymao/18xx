# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'
require_relative 'buy_train_action'

module Engine
  module Game
    module G18SJ
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include BuyTrainAction

          def actions(entity)
            # If this entity has used Motala Verkstad to buy train(s) do not allow any normal train buys
            return [] if @round.respond_to?(:premature_trains_bought) && @round.premature_trains_bought.include?(entity)

            super
          end

          def do_after_buy_train_action(_action, _entity); end

          def must_buy_train?(entity)
            return false if @game.bot_corporation?(entity)

            super
          end

          def can_entity_buy_train?(entity)
            return false if @game.bot_corporation?(entity)

            super
          end
        end
      end
    end
  end
end
