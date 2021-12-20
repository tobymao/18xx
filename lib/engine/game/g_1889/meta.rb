# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1889
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DISPLAY_TITLE = 'Shikoku 1889'

        GAME_DESIGNER = 'Yasutaka Ikeda (池田 康隆)'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1889'
        GAME_LOCATION = 'Japan'
        GAME_PUBLISHER = :grand_trunk_games
        GAME_RULES_URL = 'https://drive.google.com/file/d/1BLgIE3ihEXIjomzbEl4sIrMAz2rTlkvN/view?usp=sharing'
        GAME_ALIASES = ['History of Shikoku Railways'].freeze

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :beginner_game,
            short_name: 'Beginner Game',
            desc: 'Simpler privates, more tiles available',
          },
        ].freeze
      end
    end
  end
end
