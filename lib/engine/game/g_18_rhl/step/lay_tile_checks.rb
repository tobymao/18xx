# frozen_string_literal: true

# Note! This need to be included after the LayTileChecks in g_18_rhineland
module LayTileChecks
  def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
    super

    return unless action.tile.hex.name == 'E12'

    comp = @game.angertalbahn
    return unless comp&.owner == action.entity.player

    @log << "#{comp.name} closes"
    comp.close!
  end
end
