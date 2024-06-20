# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module GSystem18
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            entity.receivership? ? [] : super
          end

          def process_place_token(action)
            entity = action.entity

            place_token(entity, action.city, action.token,
                        same_hex_allowed: @game.token_same_hex?(entity, action.city.hex, action.token))
            pass!
          end

          def check_connected(entity, city, hex)
            @game.tokener_check_connected(entity, city, hex) && super
          end

          def tokener_available_hex(entity, hex)
            @game.tokener_available_hex(entity, hex) && super
          end
        end
      end
    end
  end
end
