# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GSystem18
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership?

            acts = super
            acts << 'sell_shares' if !acts.include?('sell_shares') && can_issue_shares?(entity)
            acts
          end

          def can_issue_shares?(entity)
            entity == current_entity && @game.can_issue_shares_for_train?(entity)
          end

          def setup
            @emr_issue = false
            super
          end

          def skip!
            @round.receivership_train_buy(self, :process_buy_train)
            @game.no_trains(current_entity) if current_entity.trains.empty? && !current_entity.receivership?
            super
          end

          def process_pass(action)
            @game.no_trains(action.entity) if action.entity.trains.empty?
            super
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

          def buy_train_action(action)
            warranted = @game.train_warranted?(action.train)
            super
            return unless warranted

            @log << "#{action.entity.name} receives a warranty for the #{action.train.name} train"
            action.train.name = action.train.name + '*'
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
