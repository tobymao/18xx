# frozen_string_literal: true

module Engine
  module Game
    module G18BF
      module Trains
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'minors_batch3' => ['3rd batch of minors',
                              'The last six minor companies become available for purchase.'],
          'privates_close' => ['Private railway companies close',
                               'All private railway companies close without compensation.'],
          'u1_available' => ['U1 available',
                             'Underground railway company U1 becomes available for purchase.'],
          'u2_available' => ['U2 available',
                             'Underground railway company U2 becomes available for purchase.'],
          'signal_end_game' => ['End of game triggered',
                                'The current set of operating rounds is completed, then there' \
                                'is a stock round followed by a set of three operating rounds.'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'minors_start' => ['Minor auctions',
                             'Minor companies can be started.'],
          'minors_convert' => ['Minors convert',
                               'Minor companies may merge, convert or be taken over.'],
          'systems_form' => ['Systems form',
                             'Systems may form by merging major companies.'],
          'double_jump' => ['Double jumps',
                            'Systems may double-jump.'],
          'train_export' => ['Train exported',
                             'A train is exported at the end of each set of operating rounds.']
        ).freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2 },
            tiles: %i[yellow],
            status: %w[minors_start],
            operating_rounds: 2,
          },
          {
            name: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[minors_start can_buy_companies minors_convert],
            on: '3',
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[minors_start can_buy_companies minors_convert train_export],
            on: '4',
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies minors_convert train_export],
            on: %w[5 3G],
            operating_rounds: 2,
          },
          {
            name: '6',
            train_limit: { minor: 1, major: 2, system: 4 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies minors_convert systems_form train_export],
            on: %w[6 4G],
            operating_rounds: 2,
          },
          {
            name: '7',
            train_limit: { minor: 1, major: 2, system: 4 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_companies minors_convert systems_form train_export],
            on: %w[3+3 5G],
            operating_rounds: 2,
          },
          {
            name: '8',
            train_limit: { minor: 0, major: 2, system: 4 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_companies minors_convert systems_form double_jump],
            on: %w[4+4 6G],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 15,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 225,
            rusts_on: '6',
            num: 11,
            events: [{ 'type' => 'minors_batch3' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 350,
            rusts_on: '4+4',
            num: 6,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 550,
            num: 6,
            variants: [
              {
                name: '3G',
                distance: [{ 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 }],
                price: 450,
              },
            ],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 3,
            variants: [
              {
                name: '4G',
                distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 }],
                price: 550,
              },
            ],
            discount: {
              '4' => 0,
              '5' => 135,
              '3G' => 125,
              '6' => 160,
              '4G' => 150,
              '3+3' => 200,
              '5G' => 175,
              '4+4' => 250,
              '6G' => 200,
              '2+2' => 150,
              '5+5E' => 375,
            },
          },
          {
            name: '3+3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 800,
            num: 3,
            variants: [
              {
                name: '5G',
                distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 }],
                price: 700,
              },
            ],
            discount: {
              '4' => 0,
              '5' => 135,
              '3G' => 125,
              '6' => 160,
              '4G' => 150,
              '3+3' => 200,
              '5G' => 175,
              '4+4' => 250,
              '6G' => 200,
              '2+2' => 150,
              '5+5E' => 375,
            },
            events: [{ 'type' => 'u1_available' }],
          },
          {
            name: '4+4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1000,
            num: 22,
            variants: [
              {
                name: '6G',
                distance: [{ 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 }],
                price: 800,
              },
            ],
            discount: {
              '4' => 0,
              '5' => 135,
              '3G' => 125,
              '6' => 160,
              '4G' => 150,
              '3+3' => 200,
              '5G' => 175,
              '4+4' => 250,
              '6G' => 200,
              '2+2' => 150,
              '5+5E' => 375,
            },
            events: [
              { 'type' => 'u2_available' },
              { 'type' => 'privates_close' },
              { 'type' => 'signal_end_game' },
            ],
          },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 600,
            num: 22,
            available_on: '8',
            discount: {
              '4' => 0,
              '5' => 135,
              '3G' => 125,
              '6' => 160,
              '4G' => 150,
              '3+3' => 200,
              '5G' => 175,
              '4+4' => 250,
              '6G' => 200,
              '2+2' => 150,
              '5+5E' => 375,
            },
          },
          {
            name: '5+5E',
            distance: [{ 'nodes' => ['offboard'], 'pay' => 5, 'visit' => 99 },
                       { 'nodes' => %w[city town], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1500,
            num: 5,
            available_on: '8',
            discount: {
              '4' => 0,
              '5' => 135,
              '3G' => 125,
              '6' => 160,
              '4G' => 150,
              '3+3' => 200,
              '5G' => 175,
              '4+4' => 250,
              '6G' => 200,
              '2+2' => 150,
              '5+5E' => 375,
            },
          },
        ].freeze

        def timeline
          @timeline = [
            'Twelve minor companies are available from the first stock round.',
            'Another six minor companies become available for purchase in stock round 2.',
            'The last six minor companes are available once the first 3-train is bought.',
            'Minors can be merged or converted into major companies from phase 3.',
            'Majors can be merged to form systems from phase 6.',
            '2+2 and 5+5E trains are available after a 4+4 or 6G train has been purchased.',
          ]
        end

        def goods_train?(train)
          train.name[-1] == 'G'
        end
      end
    end
  end
end
