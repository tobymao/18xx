# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../g_18_zoo/game'

module Engine
  module Game
    module G18ZOOMapF
      class Game < G18ZOO::Game
        include_meta(G18ZOOMapF::Meta)
        include G18ZOOMapF::Entities
        include G18ZOOMapF::Map

        STARTING_CASH = { 2 => 48, 3 => 32, 4 => 27, 5 => 22 }.freeze
      end
    end
  end
end
