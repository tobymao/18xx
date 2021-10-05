# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1872
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'Nippon'
        GAME_DESIGNER = 'Douglas Triggs'
        GAME_IMPLEMENTER = 'Douglas Triggs'
        GAME_LOCATION = 'Honshū, Japan'
        # GAME_PUBLISHER = ''
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/'
        # GAME_RULES_URL = ''

        # Beginner game for easier teaches, with some simplifications and beginner-friendly rules:
        # - Snake draft, not waterfall, hopefully with relatively-easy-to-grasp private powers
        # - First stock round reverse of draft order, then priority in reverse order of cash holdings to encourage catch-up
        # - Low player count (max 4), with low number of privates and railroads, relatively low train count
        # - Train export until phase D triggered to move along beginners and guarantee train rush
        # - Low token count, but lots geographical constraints, private available to add one additional token
        # - No yellow stock zone, only sell-then-buy to reduce stock shenanigans a bit

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
