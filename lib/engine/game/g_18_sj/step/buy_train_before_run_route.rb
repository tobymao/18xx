# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../game_error'
require_relative 'buy_train_action'

module Engine
  module Game
    module G18SJ
      module Step
        class BuyTrainBeforeRunRoute < Engine::Step::BuyTrain
          include BuyTrainAction

          MV_ACTIONS = %w[buy_train pass].freeze

          def actions(entity)
            mv_ability = ability(entity)
            return MV_ACTIONS if mv_ability&.count&.positive? && can_buy_train?(entity)

            []
          end

          def round_state
            {
              premature_trains_bought: [],
            }
          end

          def process_buy_train(action)
            from_depot = action.train.from_depot?
            raise GameError, 'Premature buys are only allowed from the Depot' unless from_depot

            buy_train_action(action)

            @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)
            @round.premature_trains_bought << action.entity

            pass! unless can_buy_train?(action.entity)
          end

          def pass!
            super
            return if @round.premature_trains_bought.empty?

            ability = ability(@game.motala_verkstad.owner)
            return unless ability

            ability.use!
            ability.desc_detail = "After use #{@game.motala_verkstad.name} has no longer any special use"
          end

          def help
            "Owning #{@game.motala_verkstad.name} gives the ability to buy trains from the Depot "\
              'before running any routes.'
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
