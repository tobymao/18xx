# frozen_string_literal: true

require_relative '../../g_1822/step/token'

module Engine
  module Game
    module G1822CA
      module Step
        class Token < G1822::Step::Token
          def place_token(entity, city, token, check_tokenable:)
            super(entity,
                  city,
                  token,
                  check_tokenable: check_tokenable,
                  same_hex_allowed: @game.class::MULTIPLE_TOKENS_ON_SAME_HEX_ALLOWED)
          end

          def process_place_token(action)
            super
            @game.after_place_token(action.entity, action.city)
          end
        end
      end
    end
  end
end
