# frozen_string_literal: true

module Engine
  module Game
    module G18Norway
      module Trains
        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            obsolete_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            obsolete_on: '5',
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            obsolete_on: 'D',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 450,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
          },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 750, '5' => 750, '6' => 750 },
          },
          {
            name: 'S3',
            distance: 3,
            price: 150,
            rusts_on: '4',
            available_on: '2',
            track_type: :narrow,
            num: 8,
          },
          {
            name: 'S4',
            distance: 4,
            price: 250,
            available_on: '3',
            rusts_on: '6',
            track_type: :narrow,
            num: 8,
          },
          {
            name: 'S5',
            distance: 4,
            price: 400,
            available_on: '5',
            track_type: :narrow,
            num: 8,
          },
        ].freeze
      end
    end
  end
end
