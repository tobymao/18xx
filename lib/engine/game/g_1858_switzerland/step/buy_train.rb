# frozen_string_literal: true

require_relative '../../g_1858/step/buy_train'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class BuyTrain < G1858::Step::BuyTrain
          ROBOT_ACTIONS = %w[buy_train].freeze

          def actions(entity)
            return super unless @game.robot_owner?(entity)
            return super unless entity.corporation?
            return [] unless @round.round_num == 2
            return [] if @train_exported

            ROBOT_ACTIONS
          end

          def auto_actions(entity)
            return super unless @game.robot_owner?(entity)
            return super unless entity.corporation?
            return [] unless @round.round_num == 2

            train = @game.depot.min_depot_train
            [Engine::Action::BuyTrain.new(entity, train: train, price: 0)]
          end

          def pass!
            return super unless @game.robot_owner?(current_entity)

            @passed = true
          end

          def skip!
            super unless @game.robot_owner?(current_entity)
          end

          def process_buy_train(action)
            @train_exported = true if @game.robot_owner?(action.entity)
            super
          end

          def spend_minmax(entity, train)
            return super unless @game.robot_owner?(entity)

            [0, 0]
          end
        end
      end
    end
  end
end
