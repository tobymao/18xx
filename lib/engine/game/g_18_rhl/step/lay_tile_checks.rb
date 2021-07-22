# frozen_string_literal: true

module LayTileChecks
  def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
    super

    @game.eastern_ruhr_connection_check(action.tile.hex)
    return if action.tile.hex.name != 'E14' || !@game.prinz_wilhelm_bahn

    # Remove hex block
    comp = @game.prinz_wilhelm_bahn
    comp.all_abilities.each do |a|
      comp.desc = 'Special ability used up. No extra effect until closed in phase 6.'
      comp.remove_ability(a)
    end
  end
end
