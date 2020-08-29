# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18MS
      class Track < Track
        ACTION_HEX_OF_INTEREST = 'B10'
        BONUS_HEX = 'B12'

        def lay_tile(action, extra_cost: 0, entity: nil)
          entity ||= action.entity
          super

          return if action.tile.hex.name != ACTION_HEX_OF_INTEREST ||
            @game.chattanooga_reached ||
            !@game.loading ||
            @game.graph.reachable_hexes(entity).find { |h, _| h.name == 'B12' }.nil?

          @game.chattanooga_reached = true
          @game.remove_icons(BONUS_HEX)
          bonus = 50
          entity.cash += bonus
          hex_name = @game.get_location_name(BONUS_HEX)
          @log << "#{entity.name} connects to #{hex_name} and receives #{@game.format_currency(bonus)}"
        end
      end
    end
  end
end
