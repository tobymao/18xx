# frozen_string_literal: true

require_relative '../g_18_new_england/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18NewEnglandNorth
      class Game < G18NewEngland::Game
        include_meta(G18NewEnglandNorth::Meta)
        include G18NewEnglandNorth::Entities
        include G18NewEnglandNorth::Map

        BANK_CASH = 6_000
        CERT_LIMIT = { 2 => 16, 3 => 12, 4 => 10 }.freeze
        STARTING_CASH = { 2 => 520, 3 => 400, 4 => 280 }.freeze
        NUM_START_MINORS = { 2 => 8, 3 => 9, 4 => 8 }.freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6E',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8E',
            num: 1,
          },
          {
            name: '5E',
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: '6E',
            distance: 6,
            price: 600,
            num: 3,
          },
          {
            name: '8E',
            distance: 8,
            price: 800,
            num: 20,
          },
        ].freeze
      end
    end
  end
end
