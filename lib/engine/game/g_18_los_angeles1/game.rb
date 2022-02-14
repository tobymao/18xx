# frozen_string_literal: true

require_relative '../g_18_los_angeles/game'
require_relative 'meta'

module Engine
  module Game
    module G18LosAngeles1
      class Game < G18LosAngeles::Game
        include_meta(G18LosAngeles1::Meta)
      end
    end
  end
end
