# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18NY
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Pierre LeBoeuf'
        GAME_PUBLISHER = :all_aboard_games
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NY'
        GAME_LOCATION = 'New York, USA'
        GAME_RULES_URL = 'https://docs.google.com/document/d/1Pz0f1Sr0uhlSpOuuXbu4OaDKIgteIyuGN55XOOLJrb0'
        GAME_TITLE = '18NY'
        GAME_VARIANTS = [
          {
            sym: :first_edition,
            name: '1st Edition',
            title: '18NY 1st Edition',
            desc: '1st Edition rules',
          },
        ].freeze

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :immediate_capitalization_round,
            short_name: 'Immediate Capitalization Round',
            desc: 'Capitalization Round occurs immediately after last 12H',
            default: true,
          },
        ].freeze
      end
    end
  end
end
