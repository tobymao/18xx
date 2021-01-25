# frozen_string_literal: true

require_relative '../g_1867/token'
require_relative 'skip_for_national'

module Engine
  module Step
    module G1861
      class Token < G1867::Token
        include SkipForNational
      end
    end
  end
end
