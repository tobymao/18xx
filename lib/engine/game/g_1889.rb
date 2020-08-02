# frozen_string_literal: true

require_relative '../config/game/g_1889'
require_relative 'base'

module Engine
  module Game
    class G1889 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1889::JSON)

      DEV_STAGE = :production

      GAME_LOCATION = 'Shikoku, Japan'
      GAME_RULES_URL = 'http://dl.deepthoughtgames.com/1889-Rules.pdf'
      GAME_DESIGNER = 'Yasutaka Ikeda (池田 康隆)'
      GAME_PUBLISHER = Publisher::INFO[:grand_trunk_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1889'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :operating_round
    end
  end
end
