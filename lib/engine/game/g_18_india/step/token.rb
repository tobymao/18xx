# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18India
      module Step
        class Token < Engine::Step::Token
          def can_place_token?(entity)
            return true if @game.abilities(entity, :token)
            return false unless current_entity == entity
            return false if @round.tokened

            tokens = available_tokens(entity)
            return false if tokens.empty?
            return false if min_token_price(tokens) > buying_power(entity)

            # move_oo_reservations moves OO corp reservations from city to tile level on yellow
            # OO tiles. This clears city @reservations, raising available_slots from 0→1 and
            # unblocking the graph walk — making OO home cities falsely appear tokenable to
            # other corps. On later upgrades (green/gray) the tile reservation is stale and
            # does not restrict placement. Apply the OO-reservation check only on yellow OO tiles.
            @game.token_graph_for_entity(entity).tokenable_cities(entity).any? do |city|
              tile = city.tile
              next true if tile.color != :yellow || tile.label.to_s != 'OO'

              tile.reservations.empty? ||
                tile.reservations.include?(entity) ||
                tile.reservations.all? { |r| tile.cities.any? { |c| c.tokens.any? { |t| t&.corporation == r } } }
            end
          end
        end
      end
    end
  end
end
