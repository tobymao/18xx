# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1840
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.corporation? || entity.type == :major

            super
          end
        end
      end
    end
  end
end
