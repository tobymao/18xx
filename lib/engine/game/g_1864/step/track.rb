# frozen_string_literal: true

require_relative '../../g_1867/step/track'

module Engine
  module Game
    module G1864
      module Step
        class Track < G1867::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            super
            @game.place_up_reserved_token!(action.hex.tile)
          end

          def tile_cost_spender(entity)
            entity.type == :national ? @game.bank : entity
          end

          def can_lay_tile?(entity)
            super || track_builder_lay?(entity)
          end

          def track_builder_lay?(entity)
            return false unless @game.track_builder?(entity)
            return false unless (tile_lay = get_tile_lay(entity))

            !entity.tokens.empty? && (tile_lay[:lay] || tile_lay[:upgrade])
          end

          def extra_lay_cost(entity, cost)
            @game.track_builder?(entity) ? 0 : cost
          end

          def terrain_cost(entity, cost)
            @game.ability_card?(entity, 'CE1') ? 0 : cost
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            @hex_terrain_cost = action.hex.tile.upgrades.sum(&:cost)
            super
          end

          def remove_border_calculate_cost!(tile, entity_or_entities, spender)
            cost, types = super
            @terrain_cost = cost + @hex_terrain_cost.to_i
            [cost, types]
          end

          def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)
            waived_extra_lay = extra_cost - extra_lay_cost(spender, extra_cost)
            waived_terrain = @terrain_cost.to_i - terrain_cost(spender, @terrain_cost.to_i)
            payable = [cost - waived_extra_lay - waived_terrain, 0].max

            payable = 0 if tile_cost_spender(spender) == @game.bank
            super(entity_or_entities, tile, rotation, hex, spender, payable, extra_cost)

            @game.pay_credit_mobilier(cost, from: @game.bank) if cost.positive?
          end
        end
      end
    end
  end
end
