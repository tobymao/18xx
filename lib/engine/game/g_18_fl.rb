# frozen_string_literal: true

require_relative '../config/game/g_18_fl'
require_relative 'base'

module Engine
  module Game
    class G18FL < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G18FL::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Florida, US'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'David Hecht'
      GAME_PUBLISHER = nil
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18FL'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :operating_round
    end
  end
end
