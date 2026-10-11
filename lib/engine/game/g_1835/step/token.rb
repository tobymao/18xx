# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step
        class Token < Engine::Step::Token
          def auto_actions(entity)
            [Engine::Action::Pass.new(entity)] unless can_place_token?(entity)
          end

          def can_place_token?(entity)
            # Cheaper to do the graph first, then check affordability
            current_entity == entity &&
              !(token = entity.next_token).nil? &&
              @game.token_graph_for_entity(entity).can_token?(entity) &&
              can_afford_token?(token, buying_power(entity))
          end

          def can_afford_token?(token, cash)
            corp = token.corporation
            @game.token_graph_for_entity(corp).tokenable_cities(corp).any? do |city|
              token_price(token, city.tile.hex) <= cash
            end
          end

          def adjust_token_price_ability!(_entity, token, hex, _city, special_ability: nil)
            token.price = token_price(token, hex)
            [token, nil]
          end

          def token_price(token, hex)
            home_hex = @game.hex_by_id(token.corporation.coordinates)
            token_cost = home_hex.distance(hex) * token.price
            return token_cost unless bayern_tokens_dresden(hex, token)

            # token cost is "as the crow flies", but the crow is not allowed to leave the board,
            # so it has to take a detour from München to Dresden. Since this is the only edge
            # case, it's much easier to implement it hard-coded than to have logic that checks
            # for the board boundaries
            token_cost + 20
          end

          def bayern_tokens_dresden(hex, token)
            hex.coordinates == 'H20' && token.corporation == @game.corporation_by_id('BY')
          end
        end
      end
    end
  end
end
