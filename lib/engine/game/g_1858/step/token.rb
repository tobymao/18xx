# frozen_string_literal: true

require_relative '../../../step/tokener'
require_relative '../../../step/token'

module Engine
  module Game
    module G1858
      module Step
        class Token < Engine::Step::Token
          # These are the number of provincial borders crossed when travelling between cities.
          # This is done as a 2D hash of city coordinates. The rows and columns are ordered
          # by province:
          #   1. Galicia (Vigo and La Coruña)
          #   2. North Portugal (Porto)
          #   3. South Portugal (Lisboa)
          #   4. Asturias (Gijón)
          #   5. Andalucía (Sevilla, Cádiz, Córdoba, Málaga and Granada)
          #   6. Cantabria (Santander)
          #   7. Castilla la Vieja (Valladolid)
          #   8. La Mancha (Madrid)
          #   9. País Vasco (Bilbao)
          #  10. Aragón (Zaragoza)
          #  11. Valenciana (Valencia)
          #  12. Murcia (Murcia)
          #  13. Cataluña (Barcelona)
          # rubocop: disable Layout/HashAlignment, Layout/MultilineHashKeyLineBreaks
          DISTANCES = {
            'B5' =>
            {
              'B5'  => 0, 'C2'  => 0, 'B9'  => 1, 'A14' => 2, 'F1'  => 1, 'E18' => 3,
              'E20' => 3, 'G18' => 3, 'G20' => 3, 'H19' => 3, 'H3'  => 2, 'G8'  => 2,
              'H11' => 2, 'I2'  => 3, 'L7'  => 3, 'L13' => 3, 'K18' => 3, 'O8'  => 4
            },
            'C2' =>
            {
              'B5'  => 0, 'C2'  => 0, 'B9'  => 1, 'A14' => 2, 'F1'  => 1, 'E18' => 3,
              'E20' => 3, 'G18' => 3, 'G20' => 3, 'H19' => 3, 'H3'  => 2, 'G8'  => 2,
              'H11' => 2, 'I2'  => 3, 'L7'  => 3, 'L13' => 3, 'K18' => 3, 'O8'  => 4
            },
            'B9' =>
            {
              'B5'  => 1, 'C2'  => 1, 'B9'  => 0, 'A14' => 1, 'F1'  => 2, 'E18' => 2,
              'E20' => 2, 'G18' => 2, 'G20' => 2, 'H19' => 2, 'H3'  => 3, 'G8'  => 2,
              'H11' => 2, 'I2'  => 3, 'L7'  => 3, 'L13' => 3, 'K18' => 3, 'O8'  => 4
            },
            'A14' =>
            {
              'B5'  => 2, 'C2'  => 2, 'B9'  => 1, 'A14' => 0, 'F1'  => 3, 'E18' => 1,
              'E20' => 1, 'G18' => 1, 'G20' => 1, 'H19' => 1, 'H3'  => 4, 'G8'  => 3,
              'H11' => 2, 'I2'  => 4, 'L7'  => 3, 'L13' => 3, 'K18' => 2, 'O8'  => 4
            },
            'F1' =>
            {
              'B5'  => 1, 'C2'  => 1, 'B9'  => 2, 'A14' => 3, 'F1'  => 0, 'E18' => 3,
              'E20' => 3, 'G18' => 3, 'G20' => 3, 'H19' => 3, 'H3'  => 1, 'G8'  => 1,
              'H11' => 2, 'I2'  => 2, 'L7'  => 2, 'L13' => 3, 'K18' => 3, 'O8'  => 3
            },
            'E18' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 2, 'A14' => 1, 'F1'  => 3, 'E18' => 0,
              'E20' => 0, 'G18' => 0, 'G20' => 0, 'H19' => 0, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 3, 'L7'  => 2, 'L13' => 2, 'K18' => 1, 'O8'  => 3
            },
            'E20' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 2, 'A14' => 1, 'F1'  => 3, 'E18' => 0,
              'E20' => 0, 'G18' => 0, 'G20' => 0, 'H19' => 0, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 3, 'L7'  => 2, 'L13' => 2, 'K18' => 1, 'O8'  => 3
            },
            'G18' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 2, 'A14' => 1, 'F1'  => 3, 'E18' => 0,
              'E20' => 0, 'G18' => 0, 'G20' => 0, 'H19' => 0, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 3, 'L7'  => 2, 'L13' => 2, 'K18' => 1, 'O8'  => 3
            },
            'G20' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 2, 'A14' => 1, 'F1'  => 3, 'E18' => 0,
              'E20' => 0, 'G18' => 0, 'G20' => 0, 'H19' => 0, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 3, 'L7'  => 2, 'L13' => 2, 'K18' => 1, 'O8'  => 3
            },
            'H19' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 2, 'A14' => 1, 'F1'  => 3, 'E18' => 0,
              'E20' => 0, 'G18' => 0, 'G20' => 0, 'H19' => 0, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 3, 'L7'  => 2, 'L13' => 2, 'K18' => 1, 'O8'  => 3
            },
            'H3' =>
            {
              'B5'  => 2, 'C2'  => 2, 'B9'  => 3, 'A14' => 4, 'F1'  => 1, 'E18' => 3,
              'E20' => 3, 'G18' => 3, 'G20' => 3, 'H19' => 3, 'H3'  => 0, 'G8'  => 1,
              'H11' => 2, 'I2'  => 1, 'L7'  => 2, 'L13' => 3, 'K18' => 3, 'O8'  => 3
            },
            'G8' =>
            {
              'B5'  => 2, 'C2'  => 2, 'B9'  => 2, 'A14' => 3, 'F1'  => 1, 'E18' => 2,
              'E20' => 2, 'G18' => 2, 'G20' => 2, 'H19' => 2, 'H3'  => 1, 'G8'  => 0,
              'H11' => 1, 'I2'  => 1, 'L7'  => 1, 'L13' => 2, 'K18' => 2, 'O8'  => 2
            },
            'H11' =>
            {
              'B5'  => 2, 'C2'  => 2, 'B9'  => 2, 'A14' => 2, 'F1'  => 2, 'E18' => 1,
              'E20' => 1, 'G18' => 1, 'G20' => 1, 'H19' => 1, 'H3'  => 2, 'G8'  => 1,
              'H11' => 0, 'I2'  => 2, 'L7'  => 1, 'L13' => 1, 'K18' => 1, 'O8'  => 2
            },
            'I2' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 3, 'A14' => 4, 'F1'  => 2, 'E18' => 3,
              'E20' => 3, 'G18' => 3, 'G20' => 3, 'H19' => 3, 'H3'  => 1, 'G8'  => 1,
              'H11' => 2, 'I2'  => 0, 'L7'  => 1, 'L13' => 2, 'K18' => 3, 'O8'  => 2
            },
            'L7' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 3, 'A14' => 3, 'F1'  => 2, 'E18' => 2,
              'E20' => 2, 'G18' => 2, 'G20' => 2, 'H19' => 2, 'H3'  => 2, 'G8'  => 1,
              'H11' => 1, 'I2'  => 1, 'L7'  => 0, 'L13' => 1, 'K18' => 2, 'O8'  => 1
            },
            'L13' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 3, 'A14' => 3, 'F1'  => 3, 'E18' => 2,
              'E20' => 2, 'G18' => 2, 'G20' => 2, 'H19' => 2, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 2, 'L7'  => 1, 'L13' => 0, 'K18' => 1, 'O8'  => 1
            },
            'K18' =>
            {
              'B5'  => 3, 'C2'  => 3, 'B9'  => 3, 'A14' => 2, 'F1'  => 3, 'E18' => 1,
              'E20' => 1, 'G18' => 1, 'G20' => 1, 'H19' => 1, 'H3'  => 3, 'G8'  => 2,
              'H11' => 1, 'I2'  => 3, 'L7'  => 2, 'L13' => 1, 'K18' => 0, 'O8'  => 2
            },
            'O8' =>
            {
              'B5'  => 4, 'C2'  => 4, 'B9'  => 4, 'A14' => 4, 'F1'  => 3, 'E18' => 3,
              'E20' => 3, 'G18' => 3, 'G20' => 3, 'H19' => 3, 'H3'  => 3, 'G8'  => 2,
              'H11' => 2, 'I2'  => 2, 'L7'  => 1, 'L13' => 1, 'K18' => 2, 'O8'  => 0
            },
          }.freeze
          # rubocop: enable Layout/HashAlignment, Layout/MultilineHashKeyLineBreaks

          def available_tokens(entity)
            return [] unless entity.corporation?

            entity.tokens_by_type
          end

          # Finds all the cities that a corporation could place a token in.
          # Does not consider whether the corporation can afford to place the token.
          def tokenable_cities(corporation)
            nodes = (@game.graph_broad.connected_nodes(corporation).keys +
                     @game.graph_metre.connected_nodes(corporation).keys).uniq
            nodes.select { |node| node.tokenable?(corporation, free: true) }
          end

          # Finds the cost of the cheapest token that can be placed by a corporation.
          def min_token_price(corporation)
            tokenable_cities(corporation).map { |city| token_cost(corporation, city) }.min
          end

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              available_tokens(entity).any? &&
              (@game.graph_broad.can_token?(entity) || @game.graph_metre.can_token?(entity)) &&
              (min_token_price(entity) <= buying_power(entity))
          end

          # Calculate the token cost from the number of provincial borders
          # crossed between an existing token and the new one.
          def token_cost(corporation, city)
            borders = corporation.placed_tokens.map do |token|
              borders_crossed(city.hex, token.city.hex)
            end.min
            [20, 40 * borders].max
          end

          def token_cost_override(entity, city, _slot, token)
            return unless entity.corporation?

            token.price = token_cost(entity, city)
          end

          def borders_crossed(hex1, hex2)
            DISTANCES[hex1.coordinates][hex2.coordinates]
          end

          def available_hex(entity, hex)
            @game.graph_broad.reachable_hexes(entity)[hex] \
              || @game.graph_metre.reachable_hexes(entity)[hex]
          end

          def check_connected(entity, city, hex)
            return if @game.loading \
              || @game.graph_broad.connected_nodes(entity)[city] \
              || @game.graph_metre.connected_nodes(entity)[city]

            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end

          def log_skip(entity)
            super unless entity.minor?
          end
        end
      end
    end
  end
end
