# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G21Moon
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        PROTOTYPE = true

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Jonas Jones and Scott Petersen'
        GAME_LOCATION = 'The Moon'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/document/d/1MZvnXckp2bGI7sHy8lAdKJ0tJ-tQi9BNpfmfax3pGHw'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/21Moon'

        PLAYER_RANGE = [2, 5].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
