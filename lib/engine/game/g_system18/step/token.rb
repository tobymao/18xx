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
        end
      end
    end
  end
end
