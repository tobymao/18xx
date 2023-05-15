# frozen_string_literal: true

require_relative '../g_18_oe/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18OEUKFR
      class Game < G18OE::Game
        include_meta(G18OEUKFR::Meta)
        include G18OEUKFR::Entities
        include G18OEUKFR::Map

        CERT_LIMIT = { 2 => 24, 3 => 16 }.freeze
        STARTING_CASH = { 2 => 870, 3 => 580 }.freeze
        BANK_CASH = 18_000

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
            price: 200,
            variants: [{
              name: '3+3',
              distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
              price: 225,
            }],
            num: 7,
          },
          {
            name: '4',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
            price: 300,
            variants: [{
              name: '4+4',
              distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
              price: 350,
            }],
            num: 3,
          },
        ].freeze

        MAX_FLOATED_REGIONALS = 6

        def setup
          super
          @minor_available_regions = %w[UK UK FR FR]

          corporations.each do |corp|
            corp.par_via_exchange = companies.find { |c| c.sym == corp.id } if corp.type == :minor
          end
        end
      end
    end
  end
end
