# frozen_string_literal: true

module LayTileChecks
  def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
    super

    @game.eastern_ruhr_connection_check(action.tile.hex)
  end
end
