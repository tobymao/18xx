# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18GB
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DISPLAY_TITLE = '18GB'

        GAME_DESIGNER = 'Dave Berry'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18GB'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/1i4Sfje2blnEIzrQi5DvISSSa1Kz2s7Ur/view'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
