# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Trains
        TRAINS = [
          {
            name: '2H',
            distance: 2,
            price: 60,
            rusts_on: '5H',
            num: 4,
          },
          {
            name: '3H',
            distance: 3,
            price: 80,
            rusts_on: '6H',
            num: 3,
          },
          {
            name: '4H',
            distance: 4,
            price: 100,
            rusts_on: '2+',
            num: 3,
          },
          {
            name: '5H',
            distance: 5,
            price: 160,
            rusts_on: '3+',
            events: [{ 'type' => 'remove_par_80' }],
            num: 3,
          },
          {
            name: '6H',
            distance: 6,
            price: 180,
            rusts_on: '4+',
            num: 2,
          },
          {
            name: '2+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 220,
            rusts_on: '7',
            num: 4,
          },
          {
            name: '3+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 240,
            rusts_on: 'D',
            events: [{ 'type' => 'remove_par_74' }],
            num: 3,
          },
          {
            name: '4+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: 'D',
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '7',
            distance: 7,
            price: 500,
            events: [{ 'type' => 'remove_par_65' }],
            num: 4,
          },
          {
            name: 'D',
            distance: 999,
            price: 600,
            num: 6,
          },
        ].freeze
      end
    end
  end
end
