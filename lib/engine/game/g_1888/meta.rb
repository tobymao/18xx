# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1888
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true

        GAME_LOCATION = 'North China'
        GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1888'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://www.lonnygames.com/app/download/13341543331/Rules_ENG.pdf'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :north,
            short_name: '1888-N',
            desc: 'North Map (3-6 players)',
            players: [3, 4, 5, 6],
            default: true,
          },
          {
            sym: :small_bank,
            short_name: 'Smaller Bank, 60% float',
            desc: '1888-N rules - Use bank of ¥9000, require 60% to float',
            hidden: true,
          },
        ].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)
          return { info: 'WARNING: No option selected. Will use North map with prototype rules' } if optional_rules.empty?
        end

        def self.min_players(optional_rules, _num_players)
          optional_rules = (optional_rules || []).map(&:to_sym)
          if optional_rules.include?(:north)
            3
          else
            2
          end
        end
      end
    end
  end
end
