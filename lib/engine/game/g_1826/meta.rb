# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1826
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Railroading in France and Belgium in 1826'
        GAME_DESIGNER = 'David Hecht'
        GAME_LOCATION = 'France and Belgium'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/1aLmPSDC4C5Xp7m5RBns5YMKe-hVlu6Rf/view?usp=sharing'
        GAME_INFO_URL = ''

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
