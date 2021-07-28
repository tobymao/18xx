# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1850
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            owner = action.entity.owner
            ability = abilities(action.entity)
            spender = action.entity.owner

            home = @game.river_corporations.include?(owner) && !owner.operated? && @game.home_hex(owner) == action.hex

            extra_cost = owner == @game.ssw_corporation && home ? -20 : 0
            lay_tile(action, spender: spender, extra_cost: extra_cost)

            check_connect(action, ability)
            ability.use!

            ability.owner.close!

            @round.num_laid_track += 1 unless home
            @round.laid_hexes << action.hex
          end
        end
      end
    end
  end
end
