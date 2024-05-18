# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Hiawatha
      module Step
        class Track < Engine::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade farms' if action.hex.assigned?('farm')

            super

            mb = @game.muntzenberger_brewery
            return if action.hex.name != @game.abilities(mb, 'tile_lay')&.hexes&.first || mb.owned_by_player?

            # MB loses its ability if something else goes on Kenosha
            @game.log << "#{mb.name} closes as it can no longer be used"
            mb.close!
          end
        end
      end
    end
  end
end
