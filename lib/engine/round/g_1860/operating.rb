# frozen_string_literal: true

require_relative '../operating'
require_relative '../../action/dividend'
require_relative '../../action/run_routes'

module Engine
  module Round
    module G1860
      class Operating < Operating
        def after_process(action)
          if (entity = @entities[@entity_index]).receivership?
            case action
            when Engine::Action::RunRoutes
              process_action(Engine::Action::Dividend.new(entity, kind: 'withhold'))
            end
          end

          super
        end
      end
    end
  end
end
