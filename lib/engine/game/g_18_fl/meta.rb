# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18FL
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Railroads to Paradise'
        GAME_DESIGNER = 'David Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18FL'
        GAME_LOCATION = 'Florida, US'
        GAME_PUBLISHER = :deep_thought_games
        GAME_RULES_URL = 'https://drive.google.com/file/d/1gnIU5v_Yv_F7E-jvX4VKWq19h7RKBx6X/view?usp=sharing'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :two_player_share_limit,
            short_name: '(2p only) 70% Corporation Holding Limit',
            desc: 'When enabled, in a 2p game a player can hold up to 70% of a corporation\'s shares',
          },
        ].freeze
      end
    end
  end
end
