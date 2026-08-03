# frozen_string_literal: true

require_relative '../../../step/token'
require_relative '../../../step/home_token'

module Engine
  module Game
    module G1835
      module Step
        class HomeToken < Engine::Step::HomeToken
          def pending_token
            # Check standard pending tokens first
            standard_pending = @round.pending_tokens&.first
            return standard_pending if standard_pending

            # Dynamically activate for Baden on its turn if L6 has track and home token is unplaced.
            # Using current_operator instead of current_entity prevents UI recursion loops.
            return {} unless @round.respond_to?(:current_operator)

            operating_entity = @round.current_operator
            return {} unless operating_entity&.id == 'BA'

            token = operating_entity.tokens.first
            return {} if !token || token.used

            hex = @game.hex_by_id('L6')
            return {} if !hex&.tile || hex.tile.color == :white

            {
              entity: operating_entity,
              hexes: [hex],
              token: token,
            }
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            token = entity.find_token_by_type

            city_name = city.hex.tile.location_name(city.index) || "slot #{city.index}"
            @game.log << "#{entity.name} places home token on #{city.hex.name} (#{city_name})"

            city.place_token(entity, token, same_hex_allowed: true)

            # Clean up the base pending_tokens array if it was populated
            @round.pending_tokens.shift unless @round.pending_tokens.empty?
          end
        end

        class Token < Engine::Step::Token
          def can_afford_token?(token, cash)
            corp = token.corporation

            @game.token_graph_for_entity(corp).tokenable_cities(corp).any? do |city|
              token_price(token, city.tile.hex) <= cash
            end
          end

          def token_price(token, hex)
            corp = token.corporation
            home_hex = @game.hex_by_id(corp.coordinates)
            return token.price if !home_hex || !hex

            distance = home_hex.distance(hex)
            token.price + (distance ? distance * 20 : 0)
          end

          def adjust_token_price_ability!(entity, token, hex, _city, special_ability: nil)
            if special_ability
              token.price = special_ability.teleport_price || special_ability.price || 0
              @game.log << "#{entity.name} uses #{special_ability.owner.name} ability to place token on #{hex.name}"
              return [token, special_ability]
            end

            token.price = token_price(token, hex)
            [token, nil]
          end
        end
      end
    end
  end
end
