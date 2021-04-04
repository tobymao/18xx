# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1846/game'

module Engine
  module Game
    module G1846TwoPlayerVariant
      class Game < G1846::Game
        include_meta(G1846TwoPlayerVariant::Meta)
      end
    end
  end
end
