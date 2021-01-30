# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CZ
      class UpgradeTrain < Base
        ACTIONS = %w[swap_train discard_train].freeze

        def actions(entity)
          return [] unless entity == buying_entity

          ACTIONS
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
          buying_entity && trains.any?
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

          variants = @game.train_information.find { |item| item[:name] == train.name }[:variants]

          raise GameError, "Train #{train.name} cannot be upgraded" if variants.nil?

          # train.variant = variants[0]

          puts train if entity.type == 'medium'
        end

        def upgrade_infos(train, _corporation)
          variants = @game.train_information.find { |item| item[:name] == train.name }[:variants]
          return nil, nil if variants.nil?

          variant_index = 0
          [variants[variant_index][:name], [(variants[variant_index][:price] - train.price), 0].max]
        end
      end
    end
  end
end
