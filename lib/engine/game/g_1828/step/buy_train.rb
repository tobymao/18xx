# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1828
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            actions = super

            # Actions in base class don't align with system behavior. Fix here.
            if entity.corporation? && must_buy_train?(entity)
              actions.delete('pass')
            elsif actions.include?('buy_train') && (@corporations_sold.empty? || @just_bought_train)
              actions << 'pass'
            end

            actions
          end

          def process_buy_train(action)
            super
            action.shell.trains << action.train if action.entity.system?
            @just_bought_train = true
          end

          def process_sell_shares(action)
            super
            @just_bought_train = false
          end

          def can_buy_train?(entity, shell = nil)
            shell_empty = shell ? shell.trains.empty? : empty_shells(entity).any?
            super || shell_empty
          end

          def room?(entity, shell = nil)
            return super unless entity.system?

            shell ? shell.trains.size < @game.train_limit(entity) : !shells_with_room(entity).empty?
          end

          def president_may_contribute?(entity, shell = nil)
            shell_empty = shell ? shell.trains.empty? : empty_shells(entity).any?

            (super || shell_empty) && ebuy_president_can_contribute?(entity)
          end

          def spend_minmax(entity, train)
            entity_buying_power = buying_power(entity)
            max_possible = entity_buying_power + entity.owner.cash
            if @last_share_sold_price
              min = max_possible - @last_share_sold_price + 1
              max = [train.price, max_possible].min
            else
              min = 1
              max = if entity_buying_power > train.price
                      entity_buying_power
                    else
                      [train.price, max_possible].min
                    end
            end
            [min, max]
          end

          private

          def shells_with_room(entity)
            return [] unless entity.system?

            entity.shells.select { |shell| shell.trains.size < @game.train_limit(entity) }
          end

          def empty_shells(entity)
            return [] unless entity.system?

            entity.shells.select { |shell| shell.trains.empty? }
          end
        end
      end
    end
  end
end
