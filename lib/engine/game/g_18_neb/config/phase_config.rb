# frozen_string_literal: true

module Engine
  module Game
    module G18Neb
      module Config
        module PhaseConfig
          PHASES = [
            {
              name: '2',
              train_limit: 4,
              tiles: [:yellow],
              operating_rounds: 2,
              status: ['can_buy_morison'],
            },
            {
              name: '3',
              on: '3+3',
              train_limit: 4,
              tiles: %i[yellow green],
              operating_rounds: 2,
              status: ['can_buy_companies'],
            },
            {
              name: '4',
              on: '4+4',
              train_limit: 3,
              tiles: %i[yellow green],
              operating_rounds: 2,
              status: ['can_buy_companies'],
            },
            {
              name: '5',
              on: '5/7',
              train_limit: 3,
              tiles: %i[yellow green brown],
              operating_rounds: 2,
            },
            {
              name: '6',
              on: '6/8',
              train_limit: 2,
              tiles: %i[yellow green brown],
              operating_rounds: 3,
            },
            {
              name: 'D',
              on: '4D',
              train_limit: 2,
              tiles: %i[yellow green brown gray],
              operating_rounds: 3,
            },
          ].freeze
        end
      end
    end
  end
end
