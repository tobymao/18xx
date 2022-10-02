# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1858
      module Step
        class Route < Engine::Step::Route
          def log_skip(entity)
            super unless entity.minor?
          end
        end
      end
    end
  end
end
