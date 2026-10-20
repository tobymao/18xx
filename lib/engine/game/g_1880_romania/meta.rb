# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1880Romania
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = '1880'

        GAME_DESIGNER = 'Lonny Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1880-Romania'
        GAME_LOCATION = 'Romania'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://www.lonnygames.com/downloads/'
        GAME_TITLE = '1880 Romania'

        PLAYER_RANGE = [2, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :kingdom_of_romania,
            short_name: 'Kingdom of Romania',
            desc: 'Regatul României map for 2-3 players',
            players: [2, 3],
          },
          {
            sym: :transylvania,
            short_name: 'Transylvania',
            desc: 'Transylvania map for 2 players',
            players: [2],
          },
        ].freeze

        VARIANT_RULES = %i[kingdom_of_romania transylvania].freeze

        def self.variant_rules(options)
          (options || []).map(&:to_sym) & VARIANT_RULES
        end

        def self.min_players(optional_rules, _num_players)
          variant_rules(optional_rules).empty? ? 3 : 2
        end

        def self.max_players(optional_rules, _num_players)
          rules = variant_rules(optional_rules)
          return 2 if rules.include?(:transylvania)

          rules.include?(:kingdom_of_romania) ? 3 : 6
        end

        def self.check_options(options, min_players, max_players)
          rules = variant_rules(options)
          if rules.empty?
            { error: '2 players requires the Kingdom of Romania or Transylvania variant' } if min_players && min_players < 3
          elsif rules.include?(:kingdom_of_romania) && rules.include?(:transylvania)
            { error: 'Kingdom of Romania and Transylvania cannot be combined' }
          elsif rules.include?(:transylvania) && max_players && max_players > 2
            { error: 'Transylvania is for 2 players' }
          elsif rules.include?(:kingdom_of_romania) && max_players && max_players > 3
            { error: 'Kingdom of Romania is for 2-3 players' }
          end
        end
      end
    end
  end
end
