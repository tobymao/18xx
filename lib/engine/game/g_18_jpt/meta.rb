# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18JPT
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_TITLE = '18JP-T'
        GAME_SUBTITLE = 'Railroading in Japan'
        GAME_LOCATION = 'Greater Tokyo'
        GAME_DESIGNER = 'Toryo Hojo'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18JPT'
        GAME_PUBLISHER = :loserdogs
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/18JPT'

        PLAYER_RANGE = [2, 7].freeze
      end
    end
  end
end
