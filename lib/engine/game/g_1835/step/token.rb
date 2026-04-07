# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1835
      module Step
        class Token < Engine::Step::Token
          COST_PER_HEX = 20

          # Called by the UI to display cost before the action is committed,
          # and by process_place_token to set the token price.
          # city_or_hex may be a City or a Hex depending on the call site.
          def token_cost_override(entity, city_or_hex, _slot, _token)
            hex = city_or_hex.respond_to?(:distance) ? city_or_hex : city_or_hex.hex
            home = home_token_hex(entity)
            return 0 unless home

            COST_PER_HEX * home.distance(hex)
          end

          def process_place_token(action)
            action.token.price = token_cost_override(action.entity, action.city, action.slot, action.token)
            super
          end

          private

          def home_token_hex(entity)
            corp = entity.company? ? entity.owner : entity
            home_token = corp.tokens.find(&:used)
            return home_token.city.hex if home_token

            @game.hex_by_id(corp.coordinates)
          end
        end
      end
    end
  end
end
