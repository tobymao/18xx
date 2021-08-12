# frozen_string_literal: true

module LayTileChecks
  def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
    super

    @game.eastern_ruhr_connection_check(action.tile.hex)
    @game.potential_icon_cleanup(action.tile)

    case action.tile.hex.name
    when 'E12'
      potentially_close_private(action, @game.angertalbahn)
    when 'E14'
      potentially_remove_ability_from_private(action, @game.prinz_wilhelm_bahn)
    end
  end

  def potentially_remove_ability_from_private(action, comp)
    return if !comp || comp.owner != action.entity.player

    # Remove hex block
    comp.desc = 'Special ability used up. No extra effect until closed in phase 6.'
    comp.all_abilities.dup.each do |a|
      comp.remove_ability(a)
    end
  end

  def potentially_close_private(action, comp)
    return unless comp&.owner == action.entity.player

    @log << "#{comp.name} closes"
    comp.close!
  end
end
