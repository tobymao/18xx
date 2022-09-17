# frozen_string_literal: true

require_relative '../../../step/tokener'
require_relative '../../../step/token'

module Engine
  module Game
    module G1858
      module Step
        class Token < Engine::Step::Token
          DISTANCES = {
            'C2' => [%w[B5], %w[F1 B9], %w[H3 G8 H11 A14], %w[E18 E20 G18 G20 H19 K18 L13 L7 I2], %w[O8]],
            'B5' => [%w[C2], %w[F1 B9], %w[H3 G8 H11 A14], %w[E18 E20 G18 G20 H19 K18 L13 L7 I2], %w[O8]],
            'F1' => [[], %w[B5 C2 G8 H3], %w[B9 H11 I2 L7], %w[E18 A14 E20 G18 G20 H19 K18 L13 O8]],
            'H3' => [[], %w[F1 G8 I2], %w[H11 L7 B5 C2], %w[E18 B9 E20 G18 G20 H19 K18 L13 O8], %w[A14]],
            'I2' => [[], %w[G8 L7 H3], %w[H11 F1 O8 L13], %w[E18 B5 C2 B9 E20 G18 G20 H19 K18], %w[A14]],
            'B9' => [[], %w[A14 B5 C2], %w[F1 G8 E18 E20 G18 G20 H19 H11], %w[H3 K18 L13 L7 I2], %w[O8]],
            'A14' => [[], %w[B9 A14 E18 E20 G18 G20 H19], %w[H11 B5 K18 C2], %w[L13 F1 G8], %w[H3 L7 I2 O8]],
            'G8' => [[], %w[F1 H3 H11 L7 I2], %w[E18 E20 G18 G20 H19 B5 C2 B9 L13 O8 K18], %w[A14]],
            'L7' => [[], %w[H11 G8 I2 O8 L13], %w[F1 H3 E18 E20 G18 G20 H19 K18], %w[A14 B5 C2 B9]],
            'O8' => [[], %w[L7 L13], %w[H11 G8 I2 K18], %w[F1 H3 E18 E20 G18 G20 H19], %w[A14 B5 C2 B9]],
            'H11' => [[], %w[G8 L7 E18 E20 G18 G20 H19 K18], %w[F1 H3 I2 B5 C2 B9 L13 O8 A14]],
            'L13' => [[], %w[L7 O8 H11 K18], %w[G8 E18 E20 G18 G20 H19], %w[I2 F1 H3 A14 B5 C2 B9]],
            'K18' => [[], %w[H11 L13 E18 E20 G18 G20 H19], %w[I2 G8 L7 O8 A14], %w[F1 H3 B5 C2 B9]],
            'E18' => [%w[E20 G18 G20 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
            'E20' => [%w[E18 G18 G20 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
            'G18' => [%w[E18 E20 G20 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
            'G20' => [%w[E18 E20 G18 H19], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
            'H19' => [%w[E18 E20 G18 G20], %w[K18 A14 H11], %w[G8 L7 L13 B9], %w[F1 H3 I2 B5 C2 O8]],
          }.freeze

          def adjust_token_price_ability!(entity, token, hex, _city, _special_ability)
            # 1858 has no special abilities to do with tokens.
            # (Ab)use this method to calculate the token cost from the number of
            # provincial borders crossed between an existing token and the new one.
            return [token, nil] unless entity.corporation?

            borders = entity.placed_tokens.map { |used_token| borders_crossed(hex, used_token.city.hex) }.min
            token.price = [20, 40 * borders].max
            [token, nil]
          end

          def borders_crossed(hex1, hex2)
            DISTANCES[hex1.coordinates].find_index { |coords| coords.include?(hex2.coordinates) }
          end

          def available_hex(entity, hex)
            @game.graph_broad.reachable_hexes(entity)[hex] \
              || @game.graph_metre.reachable_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
