# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18Texas
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def track_upgrade?(_from, to, _hex)
            to.color != :yellow
          end
        end
      end
    end
  end
end
