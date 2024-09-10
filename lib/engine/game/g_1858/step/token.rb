# frozen_string_literal: true

require_relative '../../../step/tokener'
require_relative '../../../step/token'

module Engine
  module Game
    module G1858
      module Step
        class Token < Engine::Step::Token
          def available_tokens(entity)
            return [] unless entity.corporation?

            entity.tokens_by_type
          end

          def auto_actions(entity)
            return if entity.minor?
            return if (@game.graph_broad.can_token?(entity) ||
                       @game.graph_metre.can_token?(entity)) &&
                      (min_token_price(entity) <= buying_power(entity))

            [Engine::Action::Pass.new(entity)]
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
            # Don't check for any legal token placements here, or whether the
            # corporation can afford the actual token cost here. This would
            # require the game graph to be consulted, which slows down game
            # loading. Instead auto_actions are used to pass token placement
            # if no token can be placed.
            current_entity == entity &&
              !@round.tokened &&
              !available_tokens(entity).empty?
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

          def process_place_token(action)
            # token_cost_override! is only called from the game view. When the
            # game is being loaded we need to restore the saved token cost from
            # the action, otherwise the default cost of Pt20 for a token will
            # be used.
            action.token.price = action.cost
            super
          end

          def borders_crossed(hex1, hex2)
            @game.class::TOKEN_DISTANCES[hex1.coordinates][hex2.coordinates]
          end

          def available_hex(entity, hex)
            @game.graph_broad.reachable_hexes(entity)[hex] ||
              @game.graph_metre.reachable_hexes(entity)[hex]
          end

          def check_connected(entity, city, hex)
            return if @game.loading
            return if @game.graph_broad.connected_nodes(entity)[city]
            return if @game.graph_metre.connected_nodes(entity)[city]

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
