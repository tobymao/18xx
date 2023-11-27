# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../g_18_zoo/game'

module Engine
  module Game
    module G18ZOOMapC
      class Game < G18ZOO::Game
        include_meta(G18ZOOMapC::Meta)
        include G18ZOOMapC::Entities
        include G18ZOOMapC::Map

        STARTING_CASH = { 2 => 40, 3 => 28, 4 => 23, 5 => 22 }.freeze
      end
    end
  end
end
