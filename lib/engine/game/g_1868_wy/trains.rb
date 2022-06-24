# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module Trains
        def self.def_phase(name, train_limit, tiles)
          {
            name: name,
            train_limit: train_limit,
            tiles: tiles,
            operating_rounds: 2,
            on: name,
            status: %w[can_buy_companies all_corps_available full_capitalization].take(name.to_i - 2),
          }.freeze
        end

        def self.def_train(name, price, plus_name, plus_price, num, **kwargs)
          events =
            if name.to_i >= 4
              [{ 'type' => "remove_coal_dt_#{name.to_i - 2}" }]
            else
              []
            end
          events.concat(kwargs.delete(:events) || [])

          plus_cities, plus_towns = plus_name.split('+').map(&:to_i)
          {
            name: name,
            distance: name.to_i,
            price: price,
            variants: [
              {
                name: plus_name,
                price: plus_price,
                distance: [
                  { 'nodes' => %w[city offboard], 'pay' => plus_cities, 'visit' => plus_cities },
                  { 'nodes' => ['town'], 'pay' => plus_towns, 'visit' => plus_towns },
                ],
              },
            ],
            num: num,
            events: events,
          }.merge(kwargs).freeze
        end

        PHASES = [
          def_phase('2', 4, [:yellow]),
          def_phase('3', 4, %i[yellow green]),
          def_phase('4', 3, %i[yellow green]),
          def_phase('5', 3, %i[yellow green brown]),
          def_phase('6', 2, %i[yellow green brown]),
          def_phase('7', 2, %i[yellow green brown gray]),
          def_phase('8', 2, %i[yellow green brown gray]),
        ].freeze

        TRAINS = [
          def_train('2',  80, '2+2',  120, 7, rusts_on: '4', on: nil),
          def_train('3', 180, '3+2',  220, 6, rusts_on: '6', events: [{ 'type' => 'green_par' }]),
          def_train('4', 300, '4+3',  360, 6, rusts_on: '8', events: [{ 'type' => 'all_corps_available' }]),
          def_train('5', 500, '5+4',  580, 5, events: [{ 'type' => 'full_capitalization' }, { 'type' => 'brown_par' }]),
          def_train('6', 600, '6+5',  700, 3),
          def_train('7', 800, '7+5',  900, 2),
          def_train('8', 1000, '8+5', 1100, 15),
        ].freeze
      end
    end
  end
end
