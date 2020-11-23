# frozen_string_literal: true

require_relative '../tokener'

module Engine
  module Step
    module G1860
      module Tokener
        include Step::Tokener

        def place_token(entity, city, token, teleport: false, special_ability: nil)
          hex = city.hex
          if !@game.loading && !teleport && !@game.graph.connected_nodes(entity)[city]
            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            @game.game_error("Cannot place token on #{hex.name}#{city_string} because it is not connected")
          end

          if special_ability&.city && (special_ability.city != city.index)
            @game.game_error("#{special_ability.owner.name} can only place token on #{hex.name} city "\
                             "#{special_ability.city}, not on city #{city.index}")
          end

          @game.game_error('Token is already used') if token.used

          token, ability = adjust_token_price_ability!(entity, token, hex, city)
          entity.remove_ability(ability) if ability
          free = !token.price.positive?
          city.place_token(entity, token, free: free, cheater: special_ability&.cheater)
          unless free
            # Sigh, the only reason for an 1860-specifc Token and Tokener
            entity.spend(token.price, @game.cobank)
            price_log = " for #{@game.format_currency(token.price)}"
          end

          case token.type
          when :neutral
            entity.tokens.delete(token)
            token.corporation.tokens << token
            @log << "#{entity.name} places a neutral token on #{hex.name}#{price_log}"
          else
            @log << "#{entity.name} places a token on #{hex.name} (#{hex.location_name})#{price_log}"
          end

          @game.graph.clear
        end
      end
    end
  end
end
