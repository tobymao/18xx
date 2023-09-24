# frozen_string_literal: true

module Engine
  module Game
    module G1822
      module Scenario
        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['minor_float_phase1'],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: %w[can_convert_concessions minor_float_phase2 l_upgrade],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
        ].freeze
      end
    end
  end
end
