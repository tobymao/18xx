# frozen_string_literal: true

require_relative '../../minor'
require_relative '../../share_holder'

module Engine
  module Game
    module G1880
      class Minor < Engine::Minor
        include ShareHolder
      end
    end
  end
end
