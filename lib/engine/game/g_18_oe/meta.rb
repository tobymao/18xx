# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18OE
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Edward T. Sindelar'
        GAME_PUBLISHER = :dice
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18OE'
        GAME_LOCATION = 'Europe'
        GAME_RULES_URL = 'http://www.designsice.com/files/18OE%20Rulebook.pdf'
        GAME_TITLE = '18OE'
        GAME_VARIANTS = [
          {
            sym: :oe_uk_fr,
            name: 'UK-France Scenario',
            title: '18OE UK-France Scenario',
            desc: 'UK-France Scenario',
          },
        ].freeze

        STANDARD_PLAYER_RANGE = [2, 7].freeze
        EXTENDED_PLAYER_RANGE = [3, 8].freeze
        PLAYER_RANGE = [STANDARD_PLAYER_RANGE.first, EXTENDED_PLAYER_RANGE.last].freeze

        OPTIONAL_RULES = [
          {
            sym: :fast_start,
            short_name: 'Fast Start',
            desc: 'Fixed opening packets of privates and minors; no auction or concessions (PB 5.1)',
            players: [3, 4, 5, 6, 7],
          },
          {
            sym: :medium_start,
            short_name: 'Medium Start',
            desc: 'Skip concessions and use the corresponding starting capital (PB 5.2)',
            players: [3, 4, 5, 6, 7, 8],
          },
          {
            sym: :long_endgame,
            short_name: 'Long Endgame',
            desc: 'Play the final two ORs as regular ORs',
          },
          {
            sym: :aggressive_game,
            short_name: 'Aggressive Game',
            desc: 'Play without Right-of-Way or reserved shares',
            players: [3, 4, 5, 6, 7, 8],
          },
          {
            sym: :extended_full_game,
            short_name: 'Extended Full Game',
            desc: 'Play with all 24 regionals and the extended setup (PB 5.6)',
            players: [3, 4, 5, 6, 7, 8],
          },
        ].freeze

        MUTEX_RULES = [%i[fast_start medium_start], %i[fast_start extended_full_game]].freeze

        def self.min_players(optional_rules, _num_players)
          player_range(optional_rules).first
        end

        def self.max_players(optional_rules, _num_players)
          player_range(optional_rules).last
        end

        def self.player_range(optional_rules)
          Array(optional_rules).map(&:to_sym).include?(:extended_full_game) ? EXTENDED_PLAYER_RANGE : STANDARD_PLAYER_RANGE
        end

        def self.check_options(options, _min_players, max_players)
          options = Array(options).map(&:to_sym)
          if options.include?(:extended_full_game)
            return { error: 'Fast Start and Extended Full Game cannot be combined' } if options.include?(:fast_start)

            { error: 'Extended Full Game is for 3–8 players' } if max_players && !max_players.between?(*EXTENDED_PLAYER_RANGE)
          elsif max_players && max_players > STANDARD_PLAYER_RANGE.last
            { error: 'Playing with 8 players requires Extended Full Game' }
          end
        end
      end
    end
  end
end
