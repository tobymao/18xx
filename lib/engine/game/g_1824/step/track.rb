# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../g_1837/step/skip_receivership'

module Engine
  module Game
    module G1824
      module Step
        class Track < Engine::Step::Track
          include G1837::Step::SkipReceivership
        end
      end
    end
  end
end
