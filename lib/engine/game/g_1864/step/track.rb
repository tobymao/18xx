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
          #
          # The UP has no cash and no real payer, so for its lays we must not
          # call Spender#spend at all: remapping spender to the bank would make
          # `super` do `bank.spend(cost, bank)`, which raises (spender and
          # receiver must differ), and leaving spender as the UP itself would
          # make `super` try to spend cash the UP doesn't have. Skip the
          # payment leg entirely and log the lay ourselves so it reads as the
          # Union Pacific, not the bank; the bank still funds Credit Mobilier
          # for the same amount either way.
          def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)
            if tile_cost_spender(spender) == @game.bank
              log_free_tile_lay(entity_or_entities, tile, rotation, hex, spender, cost)
            else
              super
            end

            @game.pay_credit_mobilier(cost, from: @game.bank) if cost.positive?
          end

          private

          # Mirrors Tracker#pay_tile_cost!'s log line, minus the payment leg.
          def log_free_tile_lay(entity_or_entities, tile, rotation, hex, spender, cost)
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            @log << "#{spender.name}"\
                    "#{spender == entity || !entity.company? ? '' : " (#{entities.map(&:sym).join('+')})"}"\
                    "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
                    " lays tile ##{tile.name}"\
                    " with rotation #{rotation} on #{hex.name}"\
                    "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
          end
        end
      end
    end
  end
end
