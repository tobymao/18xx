# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1822
      module Step
        class PendingToken < Engine::Step::HomeToken
          def can_replace_token?(_entity, _token)
            true
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            hex = action.city.hex
            unless available_hex(action.entity, hex)
              raise GameError, "Cannot place token on #{hex.name} as the hex is not available"
            end

            if action.city.tokened_by?(entity)
              hex = city.hex
              city_string = city.hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              raise GameError, "Can't place token on #{hex.name}#{city_string} because #{entity.id} cant have 2 "\
                               'tokens in the same city'
            end

            connected = action.entity.id != @game.class::MINOR_14_ID
            place_token(token.corporation, city, token, connected: connected, extra_action: true,
                                                        check_tokenable: false)
            @round.pending_tokens.shift
            @game.after_place_pending_token(action.city)
          end
        end
      end
    end
  end
end
