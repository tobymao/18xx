# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Trains
        TRAINS = [
          {
            name: '2',
            distance: 2,
            num: 6,
            price: 100,
            rusts_on: '4',
          },
          {
            name: '3',
            distance: 3,
            num: 5,
            price: 200,
            rusts_on: '6',
            events: [{ 'type' => 'can_buy_trains' }],
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 320,
          },
          {
            name: '5',
            distance: 5,
            num: 3,
            price: 530,
            events: [{ 'type' => 'minor_mergers_allowed' }],
          },
          {
            name: '6',
            distance: 6,
            num: 2,
            price: 670,
            events: [{ 'type' => 'minor_mergers_required' }],
          },
          {
            name: '8',
            distance: 8,
            num: 6,
            price: 900,
          },
          {
            name: '8Ox',
            distance: 8,
            num: 5,
            price: 1200,
          },
          {
            name: '1+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 6,
            price: 100,
            rusts_on: '4',
            available_on: '2',
          },
          {
            name: '2+',
            num: 4,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 120,
            rusts_on: '6',
            available_on: '3',
          },
          {
            name: '3+',
            num: 3,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 160,
            rusts_on: '6',
            available_on: '3',
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'can_buy_trains' => ['Can buy trains', 'Corporations can buy trains from other corporations'],
          'minor_mergers_allowed' => ['Minor mergers allowed', 'Minors can merge to form Lokalbahn AGs'],
          'minor_mergers_required' => ['Minor mergers required',
                                       'All minors must merge to form Lokalbahn AGs at the next OR round change'],
        ).freeze
      end
    end
  end
end
