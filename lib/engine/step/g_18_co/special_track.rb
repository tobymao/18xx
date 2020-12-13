# frozen_string_literal: true

require_relative '../special_track'
require_relative 'tracker'

module Engine
  module Step
    module G18CO
      class SpecialTrack < SpecialTrack
        include Tracker

        def process_lay_tile(action)
          ability = tile_lay_abilities(action.entity)
          lay_tile(action, spender: action.entity.owner)
          check_connect(action, ability)
          ability.use!

          @company = ability.count.positive? ? action.entity : nil if ability.must_lay_together

          clear_upgrade_icon(action.hex.tile)
          collect_mines(action.entity.owner, action.hex)

          return if ability.count.positive?

          action.entity.close!
          @game.log << "#{action.entity.name} closes"
        end
      end
    end
  end
end
