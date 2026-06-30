# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Trains
        TRAINS = [
          {
            name: 'C2',
            distance: 2,
            track_type: :broad,
            price: 40,
            rusts_on: 'CM',
            num: 5,
          },
          {
            name: 'CM',
            distance: 8,
            track_type: :broad,
            price: 100,
            num: 4,
            available_on: 'E3',
          },
          {
            name: 'V2',
            distance: 2,
            track_type: :narrow,
            price: 90,
            rusts_on: 'V4',
            num: 5,
            available_on: 'E1',
          },
          {
            name: 'V3',
            distance: 3,
            track_type: :narrow,
            price: 180,
            rusts_on: 'VE',
            num: 4,
            available_on: 'E1',
          },
          {
            name: 'V4',
            distance: 4,
            track_type: :narrow,
            price: 360,
            num: 3,
            available_on: 'E3',
            events: [{ 'type' => 'clv_available' }],
          },
          {
            name: 'VE',
            distance: 99,
            track_type: :narrow,
            price: 720,
            num: 6,
            discount: { 'V4' => 120 },
            available_on: 'E4',
          },
        ].freeze
      end
    end
  end
end
