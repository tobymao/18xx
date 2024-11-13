# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GSystem18
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership?

            super
          end

          def setup
            @emr_issue = false
            super
          end

          def skip!
            @round.receivership_train_buy(self, :process_buy_train)
          end

          def process_sell_shares(action)
            return super unless action.entity == current_entity
            raise GameError, "Cannot sell shares of #{action.bundle.corporation.name}" unless can_sell?(action.entity,
                                                                                                        action.bundle)

            @emr_issue = true

            movement_type = @game.movement_type_at_emr_share_issue_by_map

            @game.sell_shares_and_change_price(action.bundle, movement: movement_type)
          end

          def process_buy_train(action)
            super
            @emr_issue = false
          end

          def other_trains(entity)
            return super unless @emr_issue

            []
          end
        end
      end
    end
  end
end
