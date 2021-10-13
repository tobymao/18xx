# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18CZ
      module Step
        class UpgradeOrDiscardTrain < Engine::Step::Base
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
            "Upgrade or scrap bought trains #{buying_entity.name}"
          end

          def process_discard_train(action)
            train = action.train

            @game.remove_train(train)
            trains.delete(train)
            train.owner = nil

            @log << "#{action.entity.name} scraps #{train.name}"

            @round.bought_trains.shift if trains.empty?
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

            @game.rust_trains!(train, entity)

            @round.bought_trains.shift if trains.empty?
          end

          def pass!
            super
            @round.bought_trains.shift
          end

          def upgrade_infos(train, corporation)
            variant = train.variants.values.find { |item| @game.train_of_size?(item, corporation.type) }
            return nil, nil if !variant || @game.variant_is_rusted?(variant)

            upgrade_price = [(variant[:price] - train.price), 0].max
            [variant[:name], upgrade_price]
          end
        end
      end
    end
  end
end
