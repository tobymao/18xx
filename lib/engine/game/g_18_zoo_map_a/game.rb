# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../g_18_zoo/game'

module Engine
  module Game
    module G18ZOOMapA
      class Game < G18ZOO::Game
        include_meta(G18ZOOMapA::Meta)
        include G18ZOOMapA::Entities
        include G18ZOOMapA::Map

        STARTING_CASH = { 2 => 40, 3 => 28, 4 => 27, 5 => 22 }.freeze
      end
    end
  end
end
