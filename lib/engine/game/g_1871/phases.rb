# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Phases
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_par_80' => [
            '$80 par removed',
            'Parring at $80 is no longer an option.',
          ],
          'remove_par_74' => [
            '$74 par removed',
            'Parring at $74 is no longer an option.',
          ],
          'remove_par_65' => [
            '$65 par removed',
            'Parring at $65 is no longer an option.',
          ],
        ).freeze

        PHASES = [
          {
            name: '2H',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 1,
          },
          {
            name: '3H',
            on: '3H',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 1,
          },
          {
            name: '4H',
            on: '4H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '5H',
            on: '5H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '3+',
            on: '3+',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '4+',
            on: '4+',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze
      end
    end
  end
end
