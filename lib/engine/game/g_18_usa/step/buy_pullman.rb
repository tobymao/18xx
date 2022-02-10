# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/train'

module Engine
  module Game
    module G18USA
      module Step
        class BuyPullman < Engine::Step::Base
          include Engine::Step::Train
          def actions(entity)
            return [] if entity != current_entity

            if @game.depot.upcoming.any? { |t| t.name == 'P' } && can_buy_train?(entity) && @game.pullmans_available? && \
                entity.runnable_trains.none? { |t| @game.pullman_train?(t) }
              return %w[buy_train pass]
            end

            []
          end

          def description
            'Buy Pullman (Early)'
          end

          def pass_description
            'Skip (Pullman)'
          end

          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)
            pass! if !can_buy_train?(action.entity) && pass_if_cannot_buy_train?(action.entity)
          end

          def check_spend(action)
            return if action.train.price <= buying_power(action.entity)

            raise GameError, "#{action.entity.name} may not spend "\
                             "#{@game.format_currency(action.price)} on "\
                             "#{action.train.owner.name}'s #{action.train.name} "\
                             "train; may only spend #{@game.format_currency(buying_power(action.entity))}."
          end

          def buyable_trains(entity)
            # Can't buy a second pullman and can't buy a pullman if it's not legal to well, buy pullmans.
            [] if entity.runnable_trains.any? { |t| @game.pullman_train?(t) } || !@game.pullmans_available?
            # Cannot buy a pullman if you have a pullman
            Array(@game.depot.upcoming.find { |t| @game.pullman_train?(t) })
          end
        end
      end
    end
  end
end
