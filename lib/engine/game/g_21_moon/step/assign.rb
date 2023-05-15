# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G21Moon
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            super

            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
