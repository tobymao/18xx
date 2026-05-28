# frozen_string_literal: true

module Engine
  module Game
    module G1832
      module Trains
        EARLY_TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 450,
            rusts_on: '12',
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
            events: [{ 'type' => 'final_merger_chance' }, { 'type' => 'remove_tokens' }],
          },
        ].freeze

        STANDARD_LATE_TRAINS = [
          {
            name: '8',
            distance: 8,
            price: 800,
            num: 3,
            events: [{ 'type' => 'remove_key_west_token' }],
          },
          {
            name: '10',
            distance: 10,
            price: 950,
            num: 2,
          },
          {
            name: '12',
            distance: 12,
            price: 1100,
            num: 'unlimited',
          },
        ].freeze

        DIESEL_LATE_TRAINS = [
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 'unlimited',
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
            events: [{ 'type' => 'remove_key_west_token' }],
          },
        ].freeze
      end
    end
  end
end
