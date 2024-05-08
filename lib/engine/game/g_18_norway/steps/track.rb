# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Norway
      module Step
        class Track < Engine::Step::Track
          def setup
            @round.mountain_hex = nil
          end

          def process_lay_tile(action)
            @round.mountain_hex = action.hex if @game.mountain?(action.hex)
            super
          end

          def round_state
            super.merge({ mountain_hex: nil })
          end
        end
      end
    end
  end
end
