# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G18CO
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include G18CO::Tracker

          def process_lay_tile(action)
            ability = abilities(action.entity)
            lay_tile(action, spender: action.entity.owner)
            check_connect(action, ability)
            ability.use!

            @company = ability.count.positive? ? action.entity : nil if ability.must_lay_together

            clear_upgrade_icon(action.hex.tile)
            collect_mines(action.entity.owner, action.hex)
            migrate_reservations(action.hex.tile)

            return if ability.count.positive?

            action.entity.close!
            @game.log << "#{action.entity.name} closes"
          end
        end
      end
    end
  end
end
