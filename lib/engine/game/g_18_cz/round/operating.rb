# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18CZ
      module Round
        class Operating < Engine::Round::Operating
          def after_process(action)
            return super if @game.multiplayer?

            entity = @entities[@entity_index]
            if @game.corporation_of_vaclav?(entity)
              case action
              when Engine::Action::RunRoutes
                process_action(Engine::Action::Dividend.new(entity, kind: 'payout')) unless action.routes.empty?
              end
            end
            super
          end
        end
      end
    end
  end
end
