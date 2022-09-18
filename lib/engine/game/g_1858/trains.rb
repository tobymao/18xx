# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Trains
        ALLOW_TRAIN_BUY_FROM_OTHERS = true
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = true
        ALLOW_OBSOLETE_TRAIN_BUY = true
        OBSOLETE_TRAINS_COUNT_FOR_LIMIT = true

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
            'green_privates_available' => ['Green privates can start',
                                           'The second set of private companies becomes available'],
            'corporations_convert' => ['5-share companies convert',
                                       'All 5-share companies convert to 10-share companies'],
            'privates_close' => ['Private companies close',
                                 'The private closure round takes place at the end of the ' \
                                 'operating round in which the first 5E/4M train is bought'],
            'check_train_rust' => ['6H/4M trains may rust',
                                   '6H and 4M trains rust when the fifth 7E/6M/5D train is bought'],
          ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'yellow_privates' => ['Yellow privates available',
                                'The first batch of private companies can be auctioned'],
          'green_privates' => ['All privates available',
                               'The first and second batches of private companies can be auctioned'],
          'public_companies' => ['Public companies available',
                                 'Public companies can be started by buying the director\'s certificate'],
          'broad_gauge' => ['Broad gauge track',
                            'Only broad gauge track can be built'],
          'narrow_gauge' => ['Broad/metre gauge track',
                             'Broad and metre gauge track can be built'],
          'dual_gauge' => ['Broad/metre/dual gauge track',
                           'Broad, metre and dual gauge track can be built'],
        ).freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[yellow_privates broad_gauge],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: %w[4H 2M],
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[green_privates narrow_gauge],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: %w[6H 3M],
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[green_privates narrow_gauge],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: %w[5E 4M],
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[public_companies dual_gauge],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: %w[6E 5M],
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[public_companies dual_gauge],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: %w[7E 6M],
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[public_companies dual_gauge],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2H',
            obsolete_on: '6H',
            rusts_on: '6E',
            distance: 2,
            price: 100,
            num: 6,
          },
          {
            name: '4H',
            obsolete_on: '6E',
            rusts_on: '7E',
            distance: 4,
            price: 200,
            num: 5,
            events: [{ 'type' => 'green_privates_available' }],
            variants: [
              {
                name: '2M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 100,
              },
            ],
          },
          {
            name: '6H',
            obsolete_on: '7E',
            rusts_on: '5D',   # FIXME: rusted by fifth 7E/6M/5D train bought
            distance: 6,
            price: 300,
            num: 4,
            variants: [
              {
                name: '3M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 200,
              },
            ],
          },
          {
            name: '5E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 500,
            num: 3,
            events: [{ 'type' => 'corporations_convert' },
                     { 'type' => 'privates_close' }],
            variants: [
              {
                name: '4M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 400,
              },
            ],
          },
          {
            name: '6E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 2,
            variants: [
              {
                name: '5M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 550,
              },
            ],
          },
          {
            name: '7E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 16,
            events: [{ 'type' => 'check_train_rust' }],
            variants: [
              {
                name: '6M',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                price: 700,
              },
            ],
          },
          {
            name: '5D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 1_100,
            num: 8,
            multiplier: 2,
            available_on: '7',
            events: [{ 'type' => 'check_train_rust' }],
          },
        ].freeze
      end
    end
  end
end
