# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../../part/upgrade'

module Engine
  module Game
    module G18EU
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::Tracker

          def process_lay_tile(action)
            action.tile.upgrades << Part::Upgrade.new(60, ['mountain'], nil) if action.hex.tile.upgrades.sum(&:cost) == 120

            super
          end
        end
      end
    end
  end
end
