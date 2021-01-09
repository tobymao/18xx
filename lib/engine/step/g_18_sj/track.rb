# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18SJ
      class Track < Track
        def setup
          super

          @main_line_improvement = nil
          @tile_lays = 0
        end

        def process_lay_tile(action)
          super
          return if action.entity.company?

          improvement = @game.main_line_improvement(action)
          @main_line_improvement = improvement if improvement
          return if (@tile_lays += 1) == 1

          raise GameError, 'Second tile lay or upgrade only allowed ' \
            'if first or second improves main lines!' unless @main_line_improvement

          @log << "#{action.entity.name} did get the 2nd tile lay/upgrade due to a main line upgrade"
        end
      end
    end
  end
end
