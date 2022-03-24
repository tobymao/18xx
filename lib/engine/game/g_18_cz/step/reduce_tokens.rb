# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G18CZ
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def description
            'Choose tokens to remove in hexes with multiple tokens'
          end

          def available_hex(entity, hex)
            return false unless entity == surviving

            surviving_token = entity.tokens.find { |t| t.used && t.city.hex == hex }
            acquired_token = others_tokens(acquired_corps).find { |t| t.used && t.city.hex == hex }

            # Force user to clear up the NY tile first, then choose the others
            if tokens_in_same_hex(entity, acquired_corps)
              surviving_token && acquired_token
            else
              false
            end
          end

          def process_remove_token(action)
            entity = action.entity
            token = action.city.tokens[action.slot]
            raise GameError, "Cannot remove #{token.corporation.name} token" unless available_hex(entity,
                                                                                                  token.city.hex)

            token.remove!
            token.price = @game.new_token_price
            @log << "#{action.entity.name} removes token from #{action.city.hex.name}"

            return if tokens_in_same_hex(entity, acquired_corps)

            move_tokens_to_surviving(entity, acquired_corps, price_for_new_token: @game.new_token_price,
                                                             check_tokenable: false)

            @game.close_corporation(acquired_corps.first)
            @round.corporations_removing_tokens = nil
          end
        end
      end
    end
  end
end
