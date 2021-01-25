# frozen_string_literal: true

require_relative '../g_1867/track'
require_relative 'skip_for_national'

module Engine
  module Step
    module G1861
      class Track < G1867::Track
        include SkipForNational
      end
    end
  end
end
