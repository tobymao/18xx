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

          def ability_card?(entity, name)
            entity.respond_to?(:companies) && entity.companies.any? { |c| c.name == name }
          end

          # Track Builder: the $20 additional-yellow-tile-lay fee (the tracker's
          # `extra_cost`, isolated from terrain/upgrade cost - see
          # `Tracker#extra_cost`) costs the company nothing.
          def extra_lay_cost(entity, cost)
            ability_card?(entity, 'Track Builder') ? 0 : cost
          end

          # Civil Engineering Firm: terrain (border) costs are free.
          def terrain_cost(entity, cost)
            ability_card?(entity, 'Civil Engineering Firm') ? 0 : cost
          end

          # Tracker#remove_border_calculate_cost! computes and returns the
          # terrain cost as a local variable inside `lay_tile`, folded into the
          # combined `cost` by the time `pay_tile_cost!` sees it - it is never
          # passed down on its own. Capture it here so `pay_tile_cost!` can
          # waive it independently of the $20 extra-lay fee, which *is* passed
          # separately (as `extra_cost`).
          def remove_border_calculate_cost!(tile, entity_or_entities, spender)
            cost, types = super
            @terrain_cost = cost
            [cost, types]
          end

          # The $20 second-yellow cost and all terrain costs go to Credit
          # Mobilier rather than the bank.
          #
          # Track Builder and Civil Engineering Firm waive their respective
          # cost from what the *company* pays, but per the rulebook the Bank
          # still funds Credit Mobilier for the full, un-waived amount either
          # way - so only the spender's payment is reduced; the Credit
          # Mobilier payment below is untouched.
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
            waived_extra_lay = extra_cost - extra_lay_cost(spender, extra_cost)
            waived_terrain = @terrain_cost.to_i - terrain_cost(spender, @terrain_cost.to_i)
            payable = [cost - waived_extra_lay - waived_terrain, 0].max

            if tile_cost_spender(spender) == @game.bank
              log_free_tile_lay(entity_or_entities, tile, rotation, hex, spender, payable)
            else
              super(entity_or_entities, tile, rotation, hex, spender, payable, extra_cost)
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
