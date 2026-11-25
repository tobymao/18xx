# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'new_london_route'

module Engine
  module Game
    module GFrost1831
      module Step
        class Track < Engine::Step::Track
          include NewLondonRoute
        end
      end
    end
  end
end
