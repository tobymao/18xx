# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../g_18_zoo/game'

module Engine
  module Game
    module G18ZOOMapD
      class Game < G18ZOO::Game
        include_meta(G18ZOOMapD::Meta)
        include G18ZOOMapD::Entities
        include G18ZOOMapD::Map

        STARTING_CASH = { 2 => 48, 3 => 32, 4 => 27, 5 => 22 }.freeze
      end
    end
  end
end
