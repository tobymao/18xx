# frozen_string_literal: true

module Engine
  module Game
    module G18MS
      module LayTileWithChattanoogaCheck
        ACTION_HEX_OF_INTEREST = 'B10'

        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          super

          entity ||= action.entity
          entity = entity.owner if entity.company?

          return if @game.chattanooga_reached ||
            action.tile.hex.name != ACTION_HEX_OF_INTEREST ||
            !@game.graph.reachable_hexes(entity)[@game.chattanooga_hex]

          @game.chattanooga_reached = true
          @game.remove_icons(@game.chattanooga_hex.name)
          bonus = 50
          @game.bank.spend(bonus, entity)
          location_name = @game.get_location_name(@game.chattanooga_hex.name)
          @log << "#{entity.name} connects to #{location_name} and receives #{@game.format_currency(bonus)}"
        end
      end
    end
  end
end
