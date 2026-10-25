# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18OE
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Edward T. Sindelar'
        GAME_PUBLISHER = :DICE
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18OE'
        GAME_LOCATION = 'Europe'
        GAME_RULES_URL = 'http://www.designsice.com/files/18OE%20Rulebook.pdf'
        GAME_TITLE = '18OE'
        GAME_VARIANTS = [
          {
            sym: :oe_uk_fr,
            name: 'UK-France Scenario',
            title: '18OE UK-France Scenario',
            desc: 'UK-France Scenario',
          },
        ].freeze

        PLAYER_RANGE = [2, 7].freeze

        OPTIONAL_RULES = [
          {
            sym: :medium_start,
            short_name: 'Medium Start',
            desc: 'No concessions; £5,200 starting capital (PB 5.2)',
            players: [3, 4, 5, 6, 7],
          },
        ].freeze
      end
    end
  end
end
