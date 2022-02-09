# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../action/dividend'
require_relative '../../../action/run_routes'

module Engine
  module Game
    module G18GB
      module Round
        class Operating < Engine::Round::Operating
          def after_process(action)
            if (entity = @entities[@entity_index]).receivership? || @game.insolvent?(entity)
              case action
              when Engine::Action::RunRoutes
                process_action(Engine::Action::Dividend.new(entity, kind: 'withhold')) if action.routes.any?
              end
            end

            super
          end

          def next_entity!
            after_operating(@entities[@entity_index])
            super
          end

          def after_operating(entity)
            return unless entity.corporation?

            if entity.trains.empty?
              @game.make_insolvent(entity)
            else
              @game.clear_insolvent(entity)
            end
          end
        end
      end
    end
  end
end
