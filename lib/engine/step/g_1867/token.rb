# frozen_string_literal: true

require_relative '../tokener'
require_relative '../token'

module Engine
  module Step
    module G1867
      class Token < Token
        def log_skip(entity)
          super if entity.type == :major
        end

        # @note, this is presently unused as the CPU overhead is too high
        def can_afford_token?(tokens, cash)
          token = tokens.first
          # Distance must be at least 1, so check minimum price.
          return false if cash < token.price

          corporation = token.corporation
          used_tokens = corporation.tokens.select(&:used).map { |token2| token2.city.tile.hex }

          @game.graph.tokenable_cities(corporation).any? do |city|
            hex_distance_from_token(used_tokens, city.tile.hex) * token.price < cash
          end
        end

        def hex_distance_from_token(used_tokens, hex)
          used_tokens.map { |token| token.distance(hex) }.min
        end

        def adjust_token_price_ability!(entity, token, hex, _city, _special_ability = nil)
          # 1867 has no special abilities to do with tokens.
          used_tokens = entity.tokens.select(&:used).map { |token2| token2.city.tile.hex }
          token.price = token.price * hex_distance_from_token(used_tokens, hex)
          [token, nil]
        end
      end
    end
  end
end
