# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G1880Romania
      module Step
        class Track < Engine::Step::Track
          include G1880Romania::Tracker
        end
      end
    end
  end
end
