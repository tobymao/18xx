# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18Ireland
      module Step
        class Assign < Engine::Step::Assign
          def process_assign(action)
            super
            action.entity.close!
          end
        end
      end
    end
  end
end
