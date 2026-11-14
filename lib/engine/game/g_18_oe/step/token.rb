# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class Token < Engine::Step::Token
          include SkipAbbreviatedRound

          def actions(entity)
            return [] if skip?
            return ACTIONS if entity == current_entity && !@round.tokened && @game.abilities(entity, :token)

            super
          end

          def available_hex(entity, hex)
            return nil unless @game.city_in_track_rights?(entity, hex)

            super
          end

          def process_place_token(action)
            action.cost = token_cost(action) unless @game.loading
            action.token.price = action.cost
            super
          end

          def check_connected(entity, city, hex)
            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            unless @game.city_in_track_rights?(entity, hex)
              raise GameError, "Cannot place token on #{hex.name} because it is outside #{entity.name}'s track rights zone"
            end

            return if @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]

            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end

          private

          def token_cost(action)
            cost = action.token.price + @game.cross_water_token_fee(action.entity, action.city)
            return cost if !action.cost || action.cost == cost

            raise GameError, "Token costs #{@game.format_currency(cost)}, not #{@game.format_currency(action.cost)}"
          end
        end
      end
    end
  end
end
