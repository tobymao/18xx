# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module Trains
        def self.def_phase(name, train_limit, tiles, operating_rounds: 2, status: [])
          {
            name: name,
            train_limit: train_limit,
            tiles: tiles,
            operating_rounds: operating_rounds,
            on: name,
            status: %w[can_buy_companies] + status,
          }.freeze
        end

        def self.distance(cities, towns)
          [
            { 'nodes' => ['town'], 'pay' => towns, 'visit' => towns },
            { 'nodes' => %w[city offboard town], 'pay' => cities, 'visit' => cities },
          ]
        end

        def self.def_train(name, price, plus_name, plus_price, num, **kwargs)
          events = kwargs.delete(:events) || []

          phase_num = name.to_i

          events << { 'type' => 'remove_placed_coal_dt' } if phase_num >= 4
          events << { 'type' => 'remove_unplaced_coal_dt' } if phase_num >= 3 && phase_num <= 7

          plus_cities, plus_towns = plus_name.split('+').map(&:to_i)
          {
            name: name,
            distance: phase_num,
            price: price,
            variants: [
              {
                name: plus_name,
                price: plus_price,
                distance: distance(plus_cities, plus_towns),
              },
            ],
            num: num,
            events: events,
          }.merge(kwargs).freeze
        end

        # rubocop:disable Layout/LineLength
        PHASES = [
          def_phase('2', 4, [:yellow]),
          def_phase('3', 4, %i[yellow green]),
          def_phase('4', 3, %i[yellow green]),
          def_phase('5', 3, %i[yellow green brown], status: %w[all_corps_available full_capitalization]),
          def_phase('6', 2, %i[yellow green brown], status: %w[all_corps_available full_capitalization]),
          def_phase('7', 2, %i[yellow green brown gray], operating_rounds: 3, status: %w[all_corps_available full_capitalization]),
          def_phase('8', 2, %i[yellow green brown gray], operating_rounds: 3, status: %w[all_corps_available full_capitalization]),
        ].freeze
        # rubocop:enable Layout/LineLength

        TRAINS = [
          def_train('2',  80, '2+2',  120, 7, rusts_on: '4', on: nil),
          def_train('3', 180, '3+2',  220, 6, rusts_on: '6', events: [{ 'type' => 'green_par' },
                                                                      { 'type' => 'setup_company_price_up_to_face' }]),
          def_train('4', 300, '4+3',  360, 5, rusts_on: '7', events: []),
          def_train('5', 500, '5+4',  580, 4, events: [
                      { 'type' => 'close_privates' },
                      { 'type' => 'brown_par' },
                      { 'type' => 'all_corps_available' },
                      { 'type' => 'full_capitalization' },
                      { 'type' => 'oil_companies_available' },
                      { 'type' => 'uranium_boom' },
                    ]),
          def_train('6', 600, '6+5',  700, 3, events: [
                      { 'type' => 'close_privates' },
                      { 'type' => 'uranium_boom' },
                    ]),
          def_train('7', 800, '7+5',  900, 2, events: [
                      { 'type' => 'close_privates' },
                      { 'type' => 'uranium_bust' },
                      { 'type' => 'trigger_endgame' },
                    ]),
          def_train('8', 1000, '8+5', 1100, 15, events: [
                      { 'type' => 'close_privates' },
                      { 'type' => 'close_coal_companies' },
                    ]),

          # LHP train
          { name: '2+1', distance: distance(2, 1), price: 0, num: 1 },
        ].freeze
      end
    end
  end
end
