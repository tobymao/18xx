# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class Choose < Engine::Step::Base
          def description
            'Choose a Train'
          end

          def actions(entity)
            actions = []
            actions << 'choose' if @game.p2&.owner == entity

            actions
          end

          def auto_actions(entity)
            return [Engine::Action::Choose.new(entity, choice: '2')] if entity.type == :minor

            []
          end

          def log_skip(_entity); end

          def choice_name
            'Choose train'
          end

          def choices
            { '2': '2', '1+2': '1+2' }
          end

          def blocks?
            true
          end

          def active?
            @game.p2&.owner&.corporation?
          end

          def process_choose(action)
            @game.on_acquired_train(action.entity, action.choice)
          end
        end
      end
    end
  end
end
