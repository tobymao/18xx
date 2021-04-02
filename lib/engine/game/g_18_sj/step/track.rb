# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18SJ
      module Step
        class Track < Engine::Step::Track
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

            unless @main_line_improvement
              raise GameError, 'Second tile lay or upgrade only allowed if first or second improves main lines!'
            end

            @log << "#{action.entity.name} did get the 2nd tile lay/upgrade due to a main line upgrade"
          end
        end
      end
    end
  end
end
