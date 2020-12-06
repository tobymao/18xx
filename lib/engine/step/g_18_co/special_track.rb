# frozen_string_literal: true

require_relative '../special_track'
require_relative 'tracker'

module Engine
  module Step
    module G18CO
      class SpecialTrack < SpecialTrack
        include Tracker

        def process_lay_tile(action)
          super

          clear_upgrade_icon(action.hex.tile)
          collect_mines(action.entity.owner, action.hex)
          action.entity.close! if ability.count.zero?
        end
      end
    end
  end
end
