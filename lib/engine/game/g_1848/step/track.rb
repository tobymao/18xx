# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'skip_boe'

module Engine
  module Game
    module G1848
      module Step
        class Track < Engine::Step::Track
          include SkipBoe
        end
      end
    end
  end
end
