# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1889
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Yasutaka Ikeda (池田 康隆)'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1889'
        GAME_LOCATION = 'Shikoku, Japan'
        GAME_PUBLISHER = :grand_trunk_games
        GAME_RULES_URL = 'http://dl.deepthoughtgames.com/1889-Rules.pdf'
        GAME_SUBTITLE = 'History of Shikoku Railways'
        GAME_ALIASES = ['Shikoku: 1889'].freeze

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
