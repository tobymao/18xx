# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module Trains
        # Rule XIII.2 Train Overview
        TRAIN_COUNT_STANDARD = {
          '2' => 9,
          '3' => 7,
          '4' => 4,
          '5' => 3,
          '6' => 3,
          '8' => 2,
          '10' => 20,
          '1g' => 6,
          '2g' => 5,
          '3g' => 4,
          '4g' => 3,
          '5g' => 2,
        }.freeze

        # Rule VII.11, X.1, XI.1
        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            discount: { '2' => 40 },
            events: [{ 'type' => 'buy_across' }],
          },
          {
            name: '4',
            distance: 4,
            price: 280,
            rusts_on: '8',
            events: [{ 'type' => 'close_mountain_railways' },
                     { 'type' => 'sd_formation' }],
            discount: { '3' => 90 },
          },
          {
            name: '5',
            distance: 5,
            price: 400,
            rusts_on: '10',
            events: [{ 'type' => 'exchange_coal_companies' },
                     { 'type' => 'ug_formation' }],
            discount: { '4' => 140 },
          },
          {
            name: '6',
            distance: 6,
            price: 600,
            events: [{ 'type' => 'kk_formation' }],
            discount: { '5' => 200 },
          },
          {
            name: '8',
            distance: 8,
            price: 800,
            discount: { '6' => 300 },
          },
          {
            name: '10',
            distance: 10,
            price: 1000,
            discount: { '8' => 400 },
          },
          {
            name: '1g',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 120,
            available_on: '2',
            rusts_on: %w[3g 4g 5g],
          },
          {
            name: '2g',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 240,
            available_on: '3',
            rusts_on: %w[4g 5g],
            discount: { '1g' => 60 },
          },
          {
            name: '3g',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 360,
            available_on: '4',
            rusts_on: %w[5g],
            discount: { '2g' => 120 },
          },
          {
            name: '4g',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            available_on: '6',
            discount: { '3g' => 180 },
          },
          {
            name: '5g',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            available_on: '8',
            discount: { '4g' => 300 },
          },
        ].freeze
      end
    end
  end
end
