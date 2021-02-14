# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CZ
      class UpgradeOrDiscardTrain < Base
        def actions(entity)
          return [] unless entity == buying_entity

          actions = %w[swap_train discard_train]
          actions << 'pass' if entity.trains.size <= @game.train_limit(entity)
          actions
        end

        def active_entities
          [buying_entity]
        end

        def round_state
          {
            bought_trains: [],
          }
        end

        def active?
          buying_entity && !trains.empty?
        end

        def current_entity
          buying_entity
        end

        def buying_entity
          bought_trains[:entity]
        end

        def trains
          bought_trains[:trains]
        end

        def bought_trains
          @round.bought_trains&.first || {}
        end

        def description
          "Upgrade or discard bought trains #{buying_entity.name}"
        end

        def process_discard_train(action)
          train = action.train
          @game.depot.reclaim_train(train)
          trains.delete(train)
          @log << "#{action.entity.name} discards #{train.name}"
        end

        def process_swap_train(action)
          train = action.train
          entity = action.entity

          old_train_name = train.name
          variant_name, price = upgrade_infos(train, entity)

          raise GameError, "Train #{train.name} cannot be upgraded" if variant_name.nil?

          entity.spend(price, @game.bank) if price.positive?
          train.variant = variant_name

          trains.delete(train)
          @log << "#{action.entity.name} upgrades #{old_train_name}
          to #{train.name} for #{@game.format_currency(price)}"
        end

        def process_pass(action)
          trains.clear
          super
        end

        def upgrade_infos(train, corporation)
          variant = train.variants.values.find { |item| @game.train_of_size?(item, corporation.type) }
          return nil, nil unless variant

          upgrade_price = [(variant[:price] - train.price), 0].max
          [variant[:name], upgrade_price]
        end
      end
    end
  end
end
