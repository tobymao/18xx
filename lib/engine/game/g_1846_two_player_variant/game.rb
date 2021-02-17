# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1846/game'

module Engine
  module Game
    module G1846TwoPlayerVariant
      class Game < G1846::Game
        include_meta(G1846TwoPlayerVariant::Meta)

        CERT_LIMIT = { 2 => { 5 => 19, 4 => 16 } }.freeze
      end
    end
  end
end
