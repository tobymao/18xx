# frozen_string_literal: true

require_relative '../../g_1867/step/token'

module Engine
  module Game
    module G1807
      module Step
        class Token < G1867::Step::Token
          private

          def hex_distance_from_token(used_tokens, hex)
            to = hex_on_map(hex)
            used_tokens.map { |from| hex_on_map(from).distance(to) }.min
          end

          # For token cost calculations, distances to or from London cities
          # should be calculated from the small London hex on the main map
          # (U13), not the zoomed in London hex where the tokens are located.
          def hex_on_map(hex)
            @game.london_zoomed.include?(hex) ? @game.london_small : hex
          end
        end
      end
    end
  end
end
