# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858India
      class Game < G1858::Game
        include_meta(G1858India::Meta)
        include Entities
        include Map
      end
    end
  end
end
