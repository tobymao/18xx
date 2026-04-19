# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_tokens(_entity)
            # this looks a little hacky, but without this, BY cannot have its first turn
            super(current_entity)
          end

          # def place_token(entity, city, token, connected: nil, extra_action: nil, special_ability: nil,
          # check_tokenable: nil, spender: nil, same_hex_allowed: nil)
          #   entity = current_entity
          #   super
          # end
          # def adjust_token_price_ability!(_entity, token, hex, _city, special_ability: nil)
          #   _entity = current_entity
          #   super
          # end
        end
      end
    end
  end
end
