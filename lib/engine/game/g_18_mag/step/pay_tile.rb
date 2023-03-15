# frozen_string_literal: true

module Engine
  module Game
    module G18Mag
      module Step
        module PayTile
          def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, extra_cost)
            entity_cost = cost
            entity_cost = extra_cost if (cost - extra_cost).positive? && @round.terrain_token
            @log << "#{spender.name}"\
                    "#{spender == entity ? '' : " (#{entity.sym})"}"\
                    "#{entity_cost.zero? ? '' : " spends #{@game.format_currency(entity_cost)} and"}"\
                    " lays tile ##{tile.name}"\
                    " with rotation #{rotation} on #{hex.name}"\
                    "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"

            if extra_cost.positive?
              spender.spend(extra_cost, @game.skev)
              @log << "#{@game.skev.name} earns #{@game.format_currency(extra_cost)}"
            end
            return unless (cost - extra_cost).positive?

            if @round.terrain_token
              @round.terrain_token = nil
              @game.bank.spend(cost - extra_cost, @game.sik)
            else
              spender.spend(cost - extra_cost, @game.sik)
            end
            @log << "#{@game.sik.name} earns #{@game.format_currency(cost - extra_cost)}"
          end
        end
      end
    end
  end
end
