# frozen_string_literal: true

require_relative '../../g_1867/step/token'

module Engine
  module Game
    module G1807
      module Step
        class Token < G1867::Step::Token
          def hex_distance_from_token(used_tokens, hex)
            hex = @game.london_small if @game.london_zoomed.include?(hex)
            super(used_tokens, hex)
          end
        end
      end
    end
  end
end
