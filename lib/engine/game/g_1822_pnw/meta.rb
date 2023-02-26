# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822PNW
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Ken Kuhn'.freeze
        GAME_IMPLEMENTER = 'Michael Alexander'.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822PNW'.freeze
        GAME_LOCATION = 'Pacific Northwest'.freeze
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/thread/2890404/1822pnw-public-rules-review'.freeze
        GAME_TITLE = '1822PNW'.freeze

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :one_less_l,
            short_name: 'One less L/2 train',
            desc: 'Game starts with one less L/2 train (Playtest Trial)',
          },
          {
            sym: :two_less_ls,
            short_name: 'Two less L/2 trains',
            desc: 'Game starts with two less L/2 trains.  Takes priority over earlier options. (Playtest Trial)',
          },
          {
            sym: :three_less_ls,
            short_name: 'Three less L/2 trains',
            desc: 'Game starts with three less L/2 trains.  Takes priority over earlier options. (Playtest Trial)',
          },
          {
            sym: :four_less_ls,
            short_name: 'Four less L/2 trains',
            desc: 'Game starts with four less L/2 trains.  Takes priority over earlier options. (Playtest Trial)',
          },
        ].freeze
      end
    end
  end
end
