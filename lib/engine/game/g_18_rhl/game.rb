# frozen_string_literal: true

require_relative '../g_18_rhineland/game'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G18Rhl
      class Game < G18Rhineland::Game
        include_meta(G18Rhl::Meta)
        include Map

        attr_reader :osterath_tile

        CURRENCY_FORMAT_STR = '%sM'

        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze
        LOWER_STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze
      end
    end
  end
end
