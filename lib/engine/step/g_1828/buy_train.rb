# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1828
      class BuyTrain < BuyTrain
        def process_buy_train(action)
          super

          action.shell.trains << action.train if action.entity.system?
        end

        def can_buy_train?(entity, shell = nil)
          shell_empty = shell ? shell.trains.empty? : any_shell_empty?(entity)
          super || shell_empty
        end

        def room?(entity, shell = nil)
          return super unless entity.system?
          return shell.trains.size < @game.train_limit(entity) if shell
          
          shells_with_room(entity).any?
        end

        def president_may_contribute?(entity, shell = nil)
          shell_empty = shell ? shell.trains.empty? : any_shell_empty?(entity)
          super || shell_empty
        end

        private

        def shells_with_room(entity)
          return [] unless entity.system?

          entity.shells.select { |shell| shell.trains.size < @game.train_limit(entity) }
        end
        
        def any_shell_empty?(entity)
          return false unless entity.system?
          
          entity.shells.any? { |shell| shell.trains.empty? }
        end
      end
    end
  end
end
