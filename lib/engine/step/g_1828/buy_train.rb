# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1828
      class BuyTrain < BuyTrain
        def actions(entity)
          actions = super
          actions.delete('pass') if entity.corporation? && must_buy_train?(entity)
          actions
        end

        def process_buy_train(action)
          super
          action.shell.trains << action.train if action.entity.system?
        end

        def can_buy_train?(entity, shell = nil)
          shell_empty = shell ? shell.trains.empty? : empty_shells(entity).any?
          super || shell_empty
        end

        def room?(entity, shell = nil)
          return super unless entity.system?

          shell ? shell.trains.size < @game.phase.train_limit(entity) : shells_with_room(entity).any?
        end

        def president_may_contribute?(entity, shell = nil)
          shell_empty = shell ? shell.trains.empty? : empty_shells(entity).any?

          (super || shell_empty) && ebuy_president_can_contribute?(entity)
        end

        private

        def shells_with_room(entity)
          return [] unless entity.system?

          entity.shells.select { |shell| shell.trains.size < @game.phase.train_limit(entity) }
        end

        def empty_shells(entity)
          return [] unless entity.system?

          entity.shells.select { |shell| shell.trains.empty? }
        end
      end
    end
  end
end
