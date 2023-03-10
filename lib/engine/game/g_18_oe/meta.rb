# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18OE
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Edward T. Sindelar'
        # GAME_PUBLISHER = :all_aboard_games
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NY'
        GAME_LOCATION = 'Europe'
        # GAME_RULES_URL = 'https://docs.google.com/document/d/1Pz0f1Sr0uhlSpOuuXbu4OaDKIgteIyuGN55XOOLJrb0'
        GAME_TITLE = '18OE'
        GAME_VARIANTS = [
          {
            name: 'UK-France Scenario',
            title: '18OE UK-France Scenario',
            desc: 'UK-France Scenario',
          },
        ].freeze

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
