# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Trains
        S18_STDD_TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 4 },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 3 },
          { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 2 },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 1 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        S18_STD8_TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 4 },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 3 },
          { name: '4', distance: 4, price: 300, rusts_on: '8', num: 2 },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 1 },
          {
            name: '8',
            distance: 8,
            price: 800,
            num: 20,
          },
        ].freeze

        def game_trains
          if map?(:France)
            S18_STD8_TRAINS
          else
            S18_STDD_TRAINS
          end
        end

        S18_FULLCAP_PHASES = [
          { name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        S18_INCCAP_PHASES = [
          { name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 2 },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
        ].freeze

        def game_phases
          phases = []
          proto = if capitalization_by_map == :full
                    S18_FULLCAP_PHASES
                  else
                    S18_INCCAP_PHASES
                  end

          proto.each { |pp| phases << pp.dup }

          # change last phase based on train roster
          phases[-1][:name] = game_trains.last[:name]
          phases[-1][:on] = game_trains.last[:name]

          phases
        end
      end
    end
  end
end
