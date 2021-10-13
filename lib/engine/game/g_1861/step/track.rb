# frozen_string_literal: true

require_relative '../../g_1867/step/track'
require_relative 'skip_for_national'

module Engine
  module Game
    module G1861
      module Step
        class Track < G1867::Step::Track
          include SkipForNational
        end
      end
    end
  end
end
