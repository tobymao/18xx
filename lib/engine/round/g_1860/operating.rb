# frozen_string_literal: true

require_relative '../operating'
require_relative '../../action/dividend'
require_relative '../../action/run_routes'

module Engine
  module Round
    module G1860
      class Operating < Operating
        def after_process(action)
          if (entity = @entities[@entity_index]).receivership? || @game.insolvent?(entity)
            case action
            when Engine::Action::RunRoutes
              process_action(Engine::Action::Dividend.new(entity, kind: 'withhold'))
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

          if entity.trains.empty? && @game.can_run_route?(entity)
            @game.make_insolvent(entity)
          elsif !entity.trains.empty?
            @game.clear_insolvent(entity)
          end
        end
      end
    end
  end
end
