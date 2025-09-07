# frozen_string_literal: true

require_relative '../g_1862/game'
require_relative 'meta'

module Engine
  module Game
    module G1862Solo
      class Game < G1862::Game
        include_meta(G1862Solo::Meta)
        CERT_LIMIT = {
          1 => 25,
        }.freeze

        STARTING_CASH = {
          1 => 1200,
        }.freeze
      end
    end
  end
end
