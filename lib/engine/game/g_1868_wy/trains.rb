# frozen_string_literal: true

def def_phase(name, train_limit, tiles)
  {
    name: name,
    train_limit: train_limit,
    tiles: tiles,
    operating_rounds: 2,
    on: name == '2' ? nil : name,
    status: name == '2' ? [] : ['can_buy_companies'],
  }
end

def def_train(name, price, plus_name, plus_price, num, rusts_on: nil)
  plus_cities, plus_towns = plus_name.split('+').map(&:to_i)
  {
    name: name,
    distance: name.to_i,
    price: price,
    rusts_on: rusts_on,
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
  }
end

module Engine
  module Game
    module G1868WY
      module Trains
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
          def_train('2',  80, '2+2',  120, 7, rusts_on: '4'),
          def_train('3', 180, '3+2',  220, 6, rusts_on: '6'),
          def_train('4', 300, '4+3',  360, 6, rusts_on: '8'),
          def_train('5', 440, '5+4',  520, 5),
          def_train('6', 600, '6+5',  700, 3),
          def_train('7', 780, '7+5',  880, 2),
          def_train('8', 980, '8+5', 1080, 15),
        ].freeze
      end
    end
  end
end
