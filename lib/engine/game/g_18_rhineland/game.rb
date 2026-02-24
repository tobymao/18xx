# frozen_string_literal: true

require_relative 'map'
require_relative 'meta'
require_relative '../g_18_rhl/game'

module Engine
  module Game
    module G18Rhineland
      class Game < G18Rhl::Game
        include_meta(G18Rhineland::Meta)
        include Map

        # Same as 18Rhl, but does not support 6th player
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12 }.freeze
        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360 }.freeze
        LOWER_STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300 }.freeze
      end
    end
  end
end
