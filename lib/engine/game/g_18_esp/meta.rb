# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18ESP
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_SUBTITLE = 'Spain'
        GAME_DESIGNER = 'Lonny Orgler and Enrique Trigueros'
        GAME_LOCATION = 'Spain'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = {
          '18ESP Rules' => 'https://boardgamegeek.com/filepage/299403/18esp-english-rules',
          '18ESP Playbook' => 'https://boardgamegeek.com/filepage/299500/english-playbook',
        }.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18ESP'

        PLAYER_RANGE = [3, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :core,
            short_name: 'Core game',
            desc: 'Core game without a variable setup',
          },
        ].freeze
      end
    end
  end
end
