# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1868_wy/game'

module Engine
  module Game
    module G1868WYSimple2p
      class Game < G1868WY::Game
        include_meta(G1868WYSimple2p::Meta)

        STARTING_CASH = { 2 => 1100 }.freeze
        CERT_LIMIT = { 2 => 30 }.freeze
      end
    end
  end
end
