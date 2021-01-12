# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18Mag
      class Route < Route
        def log_skip(entity)
          super unless entity.corporation?
        end
      end
    end
  end
end
