# frozen_string_literal: true

require_relative '../g_1822_ca/game'
require_relative '../g_1822_ca/scenario'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G1822CaErs
      class Game < G1822CA::Game
        include_meta(G1822CaErs::Meta)
        include Entities
        include Map
        include G1822CA::Scenario

        EXCHANGE_TOKENS = {
          'CPR' => 4,
          'GT' => 3,
          'GWR' => 3,
          'ICR' => 3,
          'NTR' => 3,
          'QMOO' => 3,
        }.freeze
      end
    end
  end
end
