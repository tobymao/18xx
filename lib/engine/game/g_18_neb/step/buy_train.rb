# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Neb
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            actions = super.dup
            return actions if !entity.corporation? || entity != current_entity

            if can_scrap_train?(entity)
              actions << 'scrap_train'
              actions << 'pass'
            end
            actions.delete('pass') unless @trains_to_replace.empty?
            actions.uniq
          end

          def help
            return super if !current_entity&.corporation? || current_entity.type != :local

            'Local corporations can only buy trains that are rusted. Additionally, they may scrap trains to '\
              'make room for new trains, provided the new trains are larger than the scrapped trains and do not '\
              'require any emergency funding to purchase.'
          end

          def buyable_trains(entity)
            super.select { |train| buyable_train?(entity, train) }
          end

          def other_trains(entity)
            return [] if @owner_sold_shares

            super.select { |train| buyable_train?(entity, train) }
          end

          def buyable_train?(entity, train)
            entity.type == :local ? train.rusted : !train.rusted
          end

          def scrap_button_text(_train)
            'Discard'
          end

          def scrappable_trains(entity)
            return [] unless entity.type == :local

            max_buyable_distance =
              buyable_trains(entity).select { |t| t.price <= entity.cash }.map { |t| train_distance(t) }.max
            return [] unless max_buyable_distance

            entity.trains.select { |t| train_distance(t) < max_buyable_distance }
          end

          def train_distance(train)
            distance = train.distance
            return distance if distance.is_a?(Numeric)

            distance.sum { |dist| dist['visit'] || dist['pay'] }
          end

          def can_scrap_train?(entity)
            !scrappable_trains(entity).empty?
          end

          def process_buy_train(action)
            super
            return unless action.entity.type == :local

            new_distance = train_distance(action.train)
            replaced = @trains_to_replace.select { |t| train_distance(t) < new_distance }.max { |t| train_distance(t) }
            @trains_to_replace.delete(replaced)
          end

          def process_scrap_train(action)
            train = action.train
            if !@game.loading && !scrappable_trains(action.entity).include?(train)
              raise GameError, "Cannot scrap #{action.train.name}"
            end

            @trains_to_replace << train
            @game.depot.reclaim_train(train)
          end

          def process_sell_shares(action)
            super
            @owner_sold_shares = true if action.entity != current_entity
          end

          def spend_minmax(entity, train)
            min, max = super
            # In EMR, can use owner's cash if the corporation has no cash
            max = entity.cash.zero? ? entity.owner.cash : entity.cash if max > entity.cash
            [min, max]
          end

          def setup
            super
            @trains_to_replace = []
            @owner_sold_shares = false
          end
        end
      end
    end
  end
end
