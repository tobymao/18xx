# frozen_string_literal: true

module Engine
  module Game
    module G18Rhl
      module Trains
        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 5,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 3,
            price: 300,
            rusts_on: '8',
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 3,
            price: 500,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 6,
            price: 600,
            available_on: '5',
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            num: 4,
            price: 800,
            available_on: '6',
          },
        ].freeze

        def game_trains
          trains = self.class::TRAINS
          return trains unless optional_ratingen_variant

          # Inject remove_tile_block event
          trains.each do |t|
            next unless t[:name] == '3'

            t[:events] = [{ 'type' => 'remove_tile_block' }]
          end
          trains
        end

        def num_trains(train)
          return train[:num] unless train[:name] == '2'

          optional_2_train ? 7 : 6
        end
      end
    end
  end
end
