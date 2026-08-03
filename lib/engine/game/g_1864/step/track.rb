# frozen_string_literal: true

require_relative '../../g_1867/step/track'

module Engine
  module Game
    module G1864
      module Step
        class Track < G1867::Step::Track
          # The UP pays nothing for extra yellow lays or terrain; the bank pays
          # Credit Mobilier on its behalf.
          def tile_cost_spender(entity)
            entity.type == :national ? @game.bank : entity
          end

          # The $20 second-yellow cost and all terrain costs go to Credit
          # Mobilier rather than the bank.
          def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)
            spender = tile_cost_spender(spender)
            super

            @game.pay_credit_mobilier(cost, from: @game.bank) if cost.positive?
          end
        end
      end
    end
  end
end
