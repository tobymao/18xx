# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18GB
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DISPLAY_TITLE = '18GB'

        GAME_DESIGNER = 'Dave Berry'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18GB'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://docs.google.com/document/d/12yNo5WAi6ywc6N5XmTl-FvAZeI5kLwCMkxhgf7jgNSk/view'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :two_player_ew,
            short_name: '2P EW',
            title: '2P East-West Scenario',
            desc: 'Play the East-West (rather than North-South) 2-player setup',
            players: [2],
          },
          {
            sym: :four_player_alt,
            short_name: '4P Alt',
            desc: 'Alternate company and corporation mix for 4 players',
            players: [4],
          },
        ].freeze
      end
    end
  end
end
