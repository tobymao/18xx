# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GSystem18
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        PROTOTYPE = true

        GAME_DESIGNER = 'Scott Petersen'
        GAME_LOCATION = 'Various'
        GAME_PUBLISHER = :all_aboard_games
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/System18'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/System18'

        PLAYER_RANGE = [1, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :map_NEUS,
            short_name: 'Map: Northeast US',
            players: [2, 3, 4],
            designer: 'Scott Petersen',
          },
          {
            sym: :map_France,
            short_name: 'Map: France',
            players: [2, 3, 4],
            designer: 'Scott Petersen',
            default: true,
          },
          {
            sym: :map_Twisting_Tracks,
            short_name: 'Map: Twisting Tracks',
            players: [2, 3, 4],
            designer: 'Scott Petersen',
          },
          {
            sym: :map_UK_Limited,
            short_name: 'Map: UK Limited',
            players: [2, 3, 4],
            designer: 'Scott Petersen',
          },
          {
            sym: :map_China_Rapid_Development,
            short_name: 'Map: China Rapid Development',
            players: [2, 3, 4],
            designer: 'Scott Petersen',
          },
          {
            sym: :map_Poland,
            short_name: 'Map: Poland',
            players: [2, 3, 4],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Britain,
            short_name: 'Map: Britain',
            players: [3, 4, 5],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Britain_N,
            short_name: 'Map: Britain-North',
            players: [2, 3],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Britain_S,
            short_name: 'Map: Britain-South',
            players: [2, 3],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Northern_Italy,
            short_name: 'Map: Northern Italy',
            players: [2, 3, 4],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_MS,
            short_name: 'Map: Mississippi',
            players: [2, 3, 4],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Scotland,
            short_name: 'Map: Scotland',
            players: [2, 3, 4],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Russia,
            short_name: 'Map: Russia',
            players: [2, 3],
            designer: 'Ian Wilson',
          },
          {
            sym: :map_Gotland,
            short_name: 'Map: Gotland',
            players: [1],
            designer: 'Pontus Nilsson',
          },
        ].freeze

        MUTEX_RULES = [OPTIONAL_RULES.map { |r| r[:sym] }].freeze
      end
    end
  end
end
