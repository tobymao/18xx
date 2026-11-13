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

          def setup
            super
            @cross_water_fee = 0
          end

          def place_token(entity, city, token, **opts)
            @cross_water_fee = @game.cross_water_token_fee(entity, city)
            super
          end

          def pay_token_cost(entity, cost, city)
            fee = @cross_water_fee
            super(entity, cost + fee, city)
            return unless fee.positive?

            @game.log << "#{entity.name} pays #{@game.format_currency(fee)} to cross water"
          end

          def check_connected(entity, city, hex)
            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            unless @game.city_in_track_rights?(entity, hex)
              raise GameError, "Cannot place token on #{hex.name} because it is outside #{entity.name}'s track rights zone"
            end

            return if @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]

            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end
        end
      end
    end
  end
end
