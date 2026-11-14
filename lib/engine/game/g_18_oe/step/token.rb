# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'cross_water_fee'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class Token < Engine::Step::Token
          include CrossWaterFee
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
            fee = cross_water_fee!(action) { @game.cross_water_token_fee(action.entity, action.city) }
            super
            pay_cross_water_fee!(action.entity, fee)
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
