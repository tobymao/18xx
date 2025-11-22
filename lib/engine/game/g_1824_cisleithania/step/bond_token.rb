# frozen_string_literal: true

require_relative '../../../step/tokener'
require_relative '../../../step/token'

module Engine
  module Game
    module G1824Cisleithania
      module Step
        class BondToken < Engine::Step::Token
          def actions(entity)
            return [] if !@game.extra_token_entity && !@game.vienna_token_entity
            return [] if entity != @game.extra_token_entity && entity != @game.vienna_token_entity

            ['place_token']
          end

          def description
            return "Put a #{@game.bond_railway.name} token in Vienna" if @game.vienna_token_entity

            "Put a #{@game.bond_railway.name} token somehwere on the board"
          end

          def active?
            @game.extra_token_entity || @game.vienna_token_entity
          end

          def process_place_token(action)
            place_token(
              @game.bond_railway,
              action.city,
              @game.bond_railway.unplaced_tokens.first,
              connected: false,
              extra_action: true,
              special_ability: nil,
              check_tokenable: false,
            )

            pass!

            if action.city.hex.id == 'E12'
              @game.clear_vienna_token_entity
            else
              @game.clear_extra_token_entity
            end
          end

          def adjust_token_price_ability!(_entity, token, _hex, _city, special_ability: nil)
            [token, nil]
          end

          def available_tokens(_entity)
            @game.bond_railway.tokens_by_type
          end

          def available_hex(_entity, hex)
            return hex.name == 'E12' if @game.vienna_token_entity

            true
          end
        end
      end
    end
  end
end
