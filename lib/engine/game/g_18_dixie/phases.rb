# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Phases
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'multiple_train_buy' => [
            'Multiple Train Buys',
            'A corporation may buy multiple trains',
          ],
        ).freeze
        PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green],
            status: [],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6+1',
            train_limit: 3,
            tiles: %i[yellow green brown],
            status: ['multiple_train_buy'],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7+3',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: ['multiple_train_buy'],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '2D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['multiple_train_buy'],
            operating_rounds: 2,
          },
          {
            name: '9',
            on: '5D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['multiple_train_buy'],
            operating_rounds: 2,
          },
        ].freeze
      end
    end
  end
end
