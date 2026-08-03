# frozen_string_literal: true

require_relative 'skip_for_national'
require_relative '../../g_1867/step/token'

module Engine
  module Game
    module G1864
      module Step
        class Token < G1867::Step::Token
          include SkipForNational
        end
      end
    end
  end
end
