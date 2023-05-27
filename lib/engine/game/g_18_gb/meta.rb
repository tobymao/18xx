# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18GB
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DISPLAY_TITLE = '18GB'

        GAME_DESIGNER = 'Dave Berry'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18GB'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://www.dropbox.com/s/uilbrqw8qyo3ves/18GB%20Rules.pdf?dl=0'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :two_player_ew,
            short_name: '2P EW',
            title: '2P East-West Scenario',
            desc: 'Play the East-West (rather than North-South) 2-player setup',
          },
          {
            sym: :four_player_alt,
            short_name: '4P Alt',
            title: '4P Alternate Setup',
            desc: 'Alternate company and corporation mix for 4 players',
          },
        ].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)

          two_player_map = optional_rules.include?(:two_player_ew) ? 'East-West' : 'North-South'
          four_player_setup = optional_rules.include?(:four_player_alt) ? 'Alternative' : 'Standard'

          {
            info: "The 2P #{two_player_map} map will be used if the game is started with 2 players. The "\
                  "4P #{four_player_setup} setup will be used if the game is started with 4 players.",
          }
        end
      end
    end
  end
end
