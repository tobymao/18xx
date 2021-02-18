# frozen_string_literal: true

require_relative '../../g_1867/step/token'
require_relative 'skip_for_national'

module Engine
  module Game
    module G1861
      module Step
        class Token < G1867::Step::Token
          include SkipForNational
        end
      end
    end
  end
end
