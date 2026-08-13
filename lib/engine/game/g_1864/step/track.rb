# frozen_string_literal: true

require_relative '../../g_1867/step/track'

module Engine
  module Game
    module G1864
      module Step
        class Track < G1867::Step::Track
          def tile_cost_spender(entity)
            entity.type == :national ? @game.bank : entity
          end

          def ability_card?(entity, name)
            entity.respond_to?(:companies) && entity.companies.any? { |c| c.name == name }
          end

          def extra_lay_cost(entity, cost)
            ability_card?(entity, Entities::TRACK_BUILDER) ? 0 : cost
          end

          def terrain_cost(entity, cost)
            ability_card?(entity, Entities::CIVIL_ENGINEERING_FIRM) ? 0 : cost
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

            if tile_cost_spender(spender) == @game.bank
              log_free_tile_lay(entity_or_entities, tile, rotation, hex, spender, payable)
            else
              super(entity_or_entities, tile, rotation, hex, spender, payable, extra_cost)
            end

            @game.pay_credit_mobilier(cost, from: @game.bank) if cost.positive?
          end

          private

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
