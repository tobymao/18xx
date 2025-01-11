# frozen_string_literal: true

require_relative '../../g_1817/step/track'
require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G18FR
      module Step
        class Track < G1817::Step::Track
          include G18FR::Tracker
        end
      end
    end
  end
end
