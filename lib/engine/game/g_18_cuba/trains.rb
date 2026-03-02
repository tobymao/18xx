# frozen_string_literal: true

module Engine
  module Game
    module G18Cuba
      module Trains
        # Currently variants 2p medium, 3p short setup. Further variant support to be added later.
        TRAIN_FOR_PLAYER_COUNT = {
          2 => { '2': 5, '3': 4, '4': 2, '5': 3, '6': 3, '8': 4, '2n': 7, '3n': 5, '4n': 4, '5n': 5 },
          3 => { '2': 7, '3': 5, '4': 3, '5': 3, '6': 3, '8': 6, '2n': 5, '3n': 5, '4n': 3, '5n': 4 },
          4 => { '2': 9, '3': 7, '4': 4, '5': 3, '6': 3, '8': 8, '2n': 7, '3n': 6, '4n': 4, '5n': 5 },
          5 => { '2': 10, '3': 8, '4': 5, '5': 3, '6': 3, '8': 10, '2n': 9, '3n': 7, '4n': 5, '5n': 6 },
          6 => { '2': 10, '3': 9, '4': 5, '5': 3, '6': 3, '8': 12, '2n': 10, '3n': 8, '4n': 6, '5n': 7 },
        }.freeze

        TRAINS = [
          # Regular Trains
          {
            name: '2',
            distance: 2,
            price: 100,
            track_type: :broad,
            rusts_on: '4',
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            track_type: :broad,
            rusts_on: '6',
            variants: [
              {
                name: '3+',
                distance: 3,
                track_type: :broad,
                price: 230,
              },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            track_type: :broad,
            rusts_on: '8',
            variants: [
              {
                name: '4+',
                distance: 4,
                track_type: :broad,
                price: 340,
              },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            track_type: :broad,
            variants: [
              {
                name: '5+',
                distance: 5,
                track_type: :broad,
                price: 550,
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            price: 600,
            track_type: :broad,
            variants: [
              {
                name: '6+',
                distance: 6,
                track_type: :broad,
                price: 660,
              },
            ],
          },
          {
            name: '8',
            distance: 8,
            price: 700,
            track_type: :broad,
            variants: [
              {
                name: '4D',
                distance: 4,
                track_type: :broad,
                price: 800,
              },
            ],
          },
          # Narrow Gauge Trains
          {
            name: '2n',
            distance: 2,
            price: 80,
            track_type: :narrow,
            rusts_on: '4',
          },
          {
            name: '3n',
            distance: 3,
            price: 160,
            track_type: :narrow,
            rusts_on: '6',
          },
          {
            name: '4n',
            distance: 4,
            price: 260,
            track_type: :narrow,
          },
          {
            name: '5n',
            distance: 5,
            price: 380,
            track_type: :narrow,
          },
          ].freeze
      end
    end
  end
end
